package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.entity.MenuItemEntity;
import com.laioffer.onlineorder.repository.MenuItemEmbeddingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;


@Service
public class MenuItemEmbeddingService {


    private static final Logger log = LoggerFactory.getLogger(MenuItemEmbeddingService.class);


    private final EmbeddingService embeddingService;
    private final MenuItemEmbeddingRepository menuItemEmbeddingRepository;


    public MenuItemEmbeddingService(
            EmbeddingService embeddingService,
            MenuItemEmbeddingRepository menuItemEmbeddingRepository
    ) {
        this.embeddingService = embeddingService;
        this.menuItemEmbeddingRepository = menuItemEmbeddingRepository;
    }


    /**
     * Computes and stores the embedding for a single menu item. Failures are logged and
     * swallowed so that a create/update menu item request never fails because of the AI
     * feature — the item just won't be findable by semantic search until it's retried.
     */
    public void computeAndStore(MenuItemEntity menuItem) {
        try {
            float[] embedding = embeddingService.embed(toEmbeddingText(menuItem));
            menuItemEmbeddingRepository.updateEmbedding(menuItem.id(), embedding);
        } catch (Exception e) {
            log.warn("Failed to compute embedding for menu item {}: {}", menuItem.id(), e.getMessage());
        }
    }


    public static String toEmbeddingText(MenuItemEntity menuItem) {
        String description = menuItem.description() == null ? "" : menuItem.description();
        return menuItem.name() + ". " + description;
    }
}
