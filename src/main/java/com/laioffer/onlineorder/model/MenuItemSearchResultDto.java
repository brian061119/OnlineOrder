package com.laioffer.onlineorder.model;


public record   MenuItemSearchResultDto(
        Long id,
        Long restaurantId,
        String name,
        String description,
        Double price,
        String imageUrl,
        Double distance
) {
}
