package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.entity.MenuItemEntity;
import com.laioffer.onlineorder.repository.MenuItemEmbeddingRepository;
import com.laioffer.onlineorder.repository.MenuItemRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;


import java.util.List;


/**
 * On every startup, batch-computes embeddings for any menu item missing one (a single
 * OpenAI call for up to 2048 items) instead of computing one embedding per item. This
 * matters because database-init.sql reseeds menu_items via raw SQL INSERTs on every
 * restart, bypassing MenuItemService entirely, so the seed rows always start with a
 * NULL embedding.
 */
@Component
public class MenuItemEmbeddingBackfillRunner implements ApplicationRunner {


    private static final Logger log = LoggerFactory.getLogger(MenuItemEmbeddingBackfillRunner.class);


    private final MenuItemRepository menuItemRepository;
    private final MenuItemEmbeddingRepository menuItemEmbeddingRepository;
    private final EmbeddingService embeddingService;


    public MenuItemEmbeddingBackfillRunner(
            MenuItemRepository menuItemRepository,
            MenuItemEmbeddingRepository menuItemEmbeddingRepository,
            EmbeddingService embeddingService
    ) {
        this.menuItemRepository = menuItemRepository;
        this.menuItemEmbeddingRepository = menuItemEmbeddingRepository;
        this.embeddingService = embeddingService;
    }


    @Override
    public void run(ApplicationArguments args) {
        try {
            List<Long> missingIds = menuItemEmbeddingRepository.findIdsMissingEmbedding();
            if (missingIds.isEmpty()) {
                return;
            }

            List<MenuItemEntity> menuItems = menuItemRepository.findAllById(missingIds);
            List<String> texts = menuItems.stream()
                    .map(MenuItemEmbeddingService::toEmbeddingText)
                    .toList();

            List<float[]> embeddings = embeddingService.embed(texts);
            for (int i = 0; i < menuItems.size(); i++) {
                menuItemEmbeddingRepository.updateEmbedding(menuItems.get(i).id(), embeddings.get(i));
            }

            log.info("Backfilled embeddings for {} menu items", menuItems.size());
        } catch (Exception e) {
            log.warn("Menu item embedding backfill failed, semantic search will be degraded until it succeeds: {}",
                    e.getMessage());
        }
    }
}
