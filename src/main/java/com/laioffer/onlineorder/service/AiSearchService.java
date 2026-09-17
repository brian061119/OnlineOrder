package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.model.MenuItemSearchResultDto;
import com.laioffer.onlineorder.repository.MenuItemEmbeddingRepository;
import org.springframework.stereotype.Service;


import java.util.List;


@Service
public class AiSearchService {


    private static final int DEFAULT_RESULT_LIMIT = 5;


    private final EmbeddingService embeddingService;
    private final MenuItemEmbeddingRepository menuItemEmbeddingRepository;


    public AiSearchService(EmbeddingService embeddingService, MenuItemEmbeddingRepository menuItemEmbeddingRepository) {
        this.embeddingService = embeddingService;
        this.menuItemEmbeddingRepository = menuItemEmbeddingRepository;
    }


    public List<MenuItemSearchResultDto> search(String query) {
        return search(query, DEFAULT_RESULT_LIMIT);
    }


    public List<MenuItemSearchResultDto> search(String query, int limit) {
        if (query == null || query.isBlank()) {
            throw new IllegalArgumentException("Please enter something to search for");
        }

        float[] queryEmbedding = embeddingService.embed(query);
        return menuItemEmbeddingRepository.findNearest(queryEmbedding, limit);
    }
}
