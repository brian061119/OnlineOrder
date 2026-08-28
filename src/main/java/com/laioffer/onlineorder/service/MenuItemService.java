package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.entity.MenuItemEntity;
import com.laioffer.onlineorder.exception.ResourceNotFoundException;
import com.laioffer.onlineorder.model.MenuItemRequestBody;
import com.laioffer.onlineorder.repository.MenuItemRepository;
import com.laioffer.onlineorder.repository.RestaurantRepository;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;


import java.util.List;


@Service
public class MenuItemService {


    private final MenuItemRepository menuItemRepository;
    private final RestaurantRepository restaurantRepository;


    public MenuItemService(MenuItemRepository menuItemRepository, RestaurantRepository restaurantRepository) {
        this.menuItemRepository = menuItemRepository;
        this.restaurantRepository = restaurantRepository;
    }


    public List<MenuItemEntity> getMenuItemsByRestaurantId(long restaurantId) {
        return menuItemRepository.getByRestaurantId(restaurantId);
    }


    public MenuItemEntity getMenuItemById(long id) {
        return menuItemRepository.findById(id).get();
    }


    @CacheEvict(cacheNames = "restaurants", allEntries = true)
    public MenuItemEntity createMenuItem(long restaurantId, MenuItemRequestBody body) {
        if (!restaurantRepository.existsById(restaurantId)) {
            throw new ResourceNotFoundException("Restaurant " + restaurantId + " not found");
        }
        MenuItemEntity menuItem = new MenuItemEntity(
                null, restaurantId, body.name(), body.description(), body.price(), body.imageUrl());
        return menuItemRepository.save(menuItem);
    }


    @CacheEvict(cacheNames = "restaurants", allEntries = true)
    public MenuItemEntity updateMenuItem(long menuItemId, MenuItemRequestBody body) {
        MenuItemEntity existing = menuItemRepository.findById(menuItemId)
                .orElseThrow(() -> new ResourceNotFoundException("Menu item " + menuItemId + " not found"));
        MenuItemEntity menuItem = new MenuItemEntity(
                menuItemId, existing.restaurantId(), body.name(), body.description(), body.price(), body.imageUrl());
        return menuItemRepository.save(menuItem);
    }


    @CacheEvict(cacheNames = "restaurants", allEntries = true)
    public void deleteMenuItem(long menuItemId) {
        if (!menuItemRepository.existsById(menuItemId)) {
            throw new ResourceNotFoundException("Menu item " + menuItemId + " not found");
        }
        menuItemRepository.deleteById(menuItemId);
    }
}
