package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.exception.AiServiceException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;


import java.util.Comparator;
import java.util.List;


@Service
public class EmbeddingService {


    private static final Logger log = LoggerFactory.getLogger(EmbeddingService.class);


    private final RestClient restClient;
    private final String apiKey;
    private final String model;


    public EmbeddingService(
            @Value("${openai.api-key}") String apiKey,
            @Value("${openai.embedding-model}") String model
    ) {
        this.apiKey = apiKey;
        this.model = model;

        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(5000);
        requestFactory.setReadTimeout(15000);

        this.restClient = RestClient.builder()
                .baseUrl("https://api.openai.com/v1")
                .requestFactory(requestFactory)
                .build();
    }


    /**
     * Embeds a batch of texts in a single OpenAI API call (up to 2048 inputs per request).
     * The returned list preserves the same order as the input list.
     */
    public List<float[]> embed(List<String> texts) {
        if (texts.isEmpty()) {
            return List.of();
        }
        try {
            EmbeddingResponse response = restClient.post()
                    .uri("/embeddings")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                    .body(new EmbeddingRequest(model, texts))
                    .retrieve()
                    .body(EmbeddingResponse.class);
            if (response == null || response.data() == null) {
                throw new AiServiceException("OpenAI embedding response was empty");
            }
            return response.data().stream()
                    .sorted(Comparator.comparingInt(EmbeddingResponse.Item::index))
                    .map(EmbeddingResponse.Item::embedding)
                    .toList();
        } catch (RestClientResponseException e) {
            log.warn("OpenAI embedding API returned {} {}: {}",
                    e.getStatusCode(), e.getStatusText(), e.getResponseBodyAsString());
            throw new AiServiceException("Failed to call OpenAI embedding API", e);
        } catch (RestClientException e) {
            throw new AiServiceException("Failed to call OpenAI embedding API", e);
        }
    }


    public float[] embed(String text) {
        return embed(List.of(text)).get(0);
    }


    private record EmbeddingRequest(String model, List<String> input) {
    }


    private record EmbeddingResponse(List<Item> data) {
        private record Item(float[] embedding, int index) {
        }
    }
}
