package com.laioffer.onlineorder.service;


import com.fasterxml.jackson.annotation.JsonProperty;
import com.laioffer.onlineorder.exception.AiServiceException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;


import java.util.List;
import java.util.Map;


/**
 * Thin wrapper around OpenAI's chat completions endpoint. Knows nothing about menu items
 * or prompts — callers pass a system/user prompt plus a JSON schema, and get back the
 * response already parsed into the requested type. Forcing a JSON schema (strict mode)
 * is what stops the model from replying with free-form text we can't parse reliably.
 */
@Service
public class ChatCompletionService {


    private static final Logger log = LoggerFactory.getLogger(ChatCompletionService.class);


    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final String apiKey;
    private final String model;


    public ChatCompletionService(
            @Value("${openai.api-key}") String apiKey,
            @Value("${openai.chat-model}") String model
    ) {
        this.apiKey = apiKey;
        this.model = model;
        // Deliberately not the app's shared ObjectMapper: that one is configured with
        // SNAKE_CASE for our own REST DTOs, but the JSON schema we send OpenAI (and the
        // records we parse it into) use camelCase, which is a separate contract.
        this.objectMapper = new ObjectMapper();

        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(5000);
        requestFactory.setReadTimeout(20000);

        this.restClient = RestClient.builder()
                .baseUrl("https://api.openai.com/v1")
                .requestFactory(requestFactory)
                .build();
    }


    public <T> T completeStructured(
            String systemPrompt,
            String userPrompt,
            String schemaName,
            Map<String, Object> jsonSchema,
            Class<T> responseType
    ) {
        try {
            ChatCompletionRequest request = new ChatCompletionRequest(
                    model,
                    List.of(
                            new ChatMessage("system", systemPrompt),
                            new ChatMessage("user", userPrompt)
                    ),
                    new ResponseFormat("json_schema", new JsonSchemaWrapper(schemaName, true, jsonSchema))
            );

            ChatCompletionResponse response = restClient.post()
                    .uri("/chat/completions")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                    .body(request)
                    .retrieve()
                    .body(ChatCompletionResponse.class);

            if (response == null || response.choices() == null || response.choices().isEmpty()) {
                throw new AiServiceException("OpenAI chat completion response was empty");
            }

            String content = response.choices().get(0).message().content();
            return objectMapper.readValue(content, responseType);
        } catch (RestClientResponseException e) {
            log.warn("OpenAI chat completion API returned {} {}: {}",
                    e.getStatusCode(), e.getStatusText(), e.getResponseBodyAsString());
            throw new AiServiceException("Failed to call OpenAI chat completion API", e);
        } catch (RestClientException | JacksonException e) {
            throw new AiServiceException("Failed to call OpenAI chat completion API", e);
        }
    }


    private record ChatCompletionRequest(
            String model,
            List<ChatMessage> messages,
            @JsonProperty("response_format") ResponseFormat responseFormat
    ) {
    }


    private record ChatMessage(String role, String content) {
    }


    private record ResponseFormat(
            String type,
            @JsonProperty("json_schema") JsonSchemaWrapper jsonSchema
    ) {
    }


    private record JsonSchemaWrapper(String name, boolean strict, Map<String, Object> schema) {
    }


    private record ChatCompletionResponse(List<Choice> choices) {
    }


    private record Choice(ChatMessageResponse message) {
    }


    private record ChatMessageResponse(String content) {
    }
}
