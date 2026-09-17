package com.laioffer.onlineorder.repository;


import com.laioffer.onlineorder.model.MenuItemSearchResultDto;
import com.pgvector.PGvector;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;


import java.util.List;


/**
 * Spring Data JDBC has no built-in mapping for the pgvector "vector" column type,
 * so embedding reads/writes go through plain JdbcTemplate with the pgvector-java
 * client (PGvector) instead of MenuItemRepository/MenuItemEntity.
 */
@Repository
public class MenuItemEmbeddingRepository {


    private final JdbcTemplate jdbcTemplate;


    public MenuItemEmbeddingRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }


    public void updateEmbedding(long menuItemId, float[] embedding) {
        jdbcTemplate.update(
                "UPDATE menu_items SET embedding = ? WHERE id = ?",
                new PGvector(embedding), menuItemId);
    }


    public List<Long> findIdsMissingEmbedding() {
        return jdbcTemplate.queryForList(
                "SELECT id FROM menu_items WHERE embedding IS NULL", Long.class);
    }


    public List<MenuItemSearchResultDto> findNearest(float[] queryEmbedding, int limit) {
        return jdbcTemplate.query(
                """
                SELECT id, restaurant_id, name, description, price, image_url,
                       embedding <=> ? AS distance
                FROM menu_items
                WHERE embedding IS NOT NULL
                ORDER BY distance
                LIMIT ?
                """,
                (rs, rowNum) -> new MenuItemSearchResultDto(
                        rs.getLong("id"),
                        rs.getLong("restaurant_id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getDouble("price"),
                        rs.getString("image_url"),
                        rs.getDouble("distance")
                ),
                new PGvector(queryEmbedding), limit);
    }
}
