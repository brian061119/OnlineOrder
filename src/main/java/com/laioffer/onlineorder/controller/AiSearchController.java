package com.laioffer.onlineorder.controller;


import com.laioffer.onlineorder.model.AiSearchRequestBody;
import com.laioffer.onlineorder.model.MenuItemSearchResultDto;
import com.laioffer.onlineorder.service.AiSearchService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;


import java.util.List;


@RestController
public class AiSearchController {


    private final AiSearchService aiSearchService;


    public AiSearchController(AiSearchService aiSearchService) {
        this.aiSearchService = aiSearchService;
    }


    @PostMapping("/ai/search")
    public List<MenuItemSearchResultDto> search(@RequestBody AiSearchRequestBody body) {
        return aiSearchService.search(body.query());
    }
}
