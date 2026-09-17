package com.laioffer.onlineorder.controller;


import com.laioffer.onlineorder.model.AiRecommendationDto;
import com.laioffer.onlineorder.model.AiRecommendationRequestBody;
import com.laioffer.onlineorder.service.AiRecommendationService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;


@RestController
public class AiRecommendationController {


    private final AiRecommendationService aiRecommendationService;


    public AiRecommendationController(AiRecommendationService aiRecommendationService) {
        this.aiRecommendationService = aiRecommendationService;
    }


    @PostMapping("/ai/recommend")
    public AiRecommendationDto recommend(@RequestBody AiRecommendationRequestBody body) {
        return aiRecommendationService.recommend(body.message());
    }
}
