package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.model.AiRecommendationDto;
import com.laioffer.onlineorder.model.MenuItemSearchResultDto;
import org.springframework.stereotype.Service;


import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;


@Service
public class AiRecommendationService {


    private static final int CANDIDATE_LIMIT = 10;
    private static final String DISCLAIMER =
            "These are suggestions only — please double-check ingredients yourself if you have allergies or dietary restrictions.";


    private static final String SYSTEM_PROMPT = """
            You are a food ordering assistant. You may only recommend items from the candidate
            menu list provided in the user message — never recommend anything outside that list,
            and never invent a menuItemId that isn't in it.
            When writing a reason, base it only on the name and description given for that candidate;
            never invent flavors, ingredients, or preparation details that aren't in the description.
            If a candidate's actual category doesn't fully match what the user asked for (e.g. the user
            wants a burger but the candidate is actually a sandwich), state its real category honestly
            instead of mislabeling it just to please the user.
            If the user's message is entirely unrelated to ordering food or getting menu recommendations
            (e.g. small talk, writing a poem, nonsense), don't force a recommendation out of the
            candidates — return an empty recommendations array and explain in summary that you can only
            help with menu recommendations.
            But if the user is genuinely asking for a type of food and the candidates just don't have an
            exact match (e.g. they want pizza but it's not on the menu), don't return an empty array —
            say so honestly and pick the closest reasonable alternatives from the candidates instead.
            Otherwise, pick the 1 to 5 best-fitting items based on the user's needs (taste, budget, etc.),
            write a short overall recommendation (summary) in English, and a one-sentence reason for
            each recommended item, also in English.
            """;


    @SuppressWarnings("unchecked")
    private static final Map<String, Object> RECOMMENDATION_SCHEMA = Map.of(
            "type", "object",
            "properties", Map.of(
                    "summary", Map.of("type", "string"),
                    "recommendations", Map.of(
                            "type", "array",
                            "items", Map.of(
                                    "type", "object",
                                    "properties", Map.of(
                                            "menuItemId", Map.of("type", "integer"),
                                            "reason", Map.of("type", "string")
                                    ),
                                    "required", List.of("menuItemId", "reason"),
                                    "additionalProperties", false
                            )
                    )
            ),
            "required", List.of("summary", "recommendations"),
            "additionalProperties", false
    );


    private final AiSearchService aiSearchService;
    private final ChatCompletionService chatCompletionService;


    public AiRecommendationService(AiSearchService aiSearchService, ChatCompletionService chatCompletionService) {
        this.aiSearchService = aiSearchService;
        this.chatCompletionService = chatCompletionService;
    }


    public AiRecommendationDto recommend(String userMessage) {
        if (userMessage == null || userMessage.isBlank()) {
            throw new IllegalArgumentException("Please tell us what you'd like to order");
        }

        List<MenuItemSearchResultDto> candidates = aiSearchService.search(userMessage, CANDIDATE_LIMIT);

        String candidateText = candidates.stream()
                .map(item -> "ID:%d Name:%s Price:%.2f Description:%s".formatted(
                        item.id(), item.name(), item.price(), item.description()))
                .collect(Collectors.joining("\n"));

        String userPrompt = "Candidate menu items:\n" + candidateText + "\n\nUser request: " + userMessage;

        ModelRecommendation modelResult = chatCompletionService.completeStructured(
                SYSTEM_PROMPT, userPrompt, "menu_recommendation", RECOMMENDATION_SCHEMA, ModelRecommendation.class);

        Map<Long, MenuItemSearchResultDto> candidatesById = candidates.stream()
                .collect(Collectors.toMap(MenuItemSearchResultDto::id, Function.identity()));

        List<AiRecommendationDto.RecommendedItem> enriched = modelResult.recommendations().stream()
                .filter(item -> candidatesById.containsKey(item.menuItemId()))
                .map(item -> {
                    MenuItemSearchResultDto menuItem = candidatesById.get(item.menuItemId());
                    return new AiRecommendationDto.RecommendedItem(
                            menuItem.id(), menuItem.name(), menuItem.price(), menuItem.imageUrl(), item.reason());
                })
                .toList();

        return new AiRecommendationDto(modelResult.summary(), enriched, DISCLAIMER);
    }


    private record ModelRecommendation(String summary, List<ModelRecommendedItem> recommendations) {
    }


    private record ModelRecommendedItem(Long menuItemId, String reason) {
    }
}
