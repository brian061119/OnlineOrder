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
    private static final String DISCLAIMER = "以上为参考推荐,如有过敏或忌口请自行确认菜品成分。";


    private static final String SYSTEM_PROMPT = """
            你是一个点餐助手。你只能从用户消息里提供的候选菜品列表中挑选推荐，
            禁止推荐清单之外的任何菜品，禁止编造不存在的 menuItemId。
            写推荐理由时只能依据候选菜品给出的名称和描述，禁止编造描述中没有出现的口味、做法或成分。
            如果某道候选菜品的实际类别跟用户要求的品类不完全一致（比如用户要汉堡，候选里其实是三明治），
            必须如实说明它的真实类别，不能为了迎合用户而把它错误地称作用户要的品类。
            如果用户的消息本身完全跟点餐、菜品推荐无关（比如闲聊、写诗等无意义内容），
            不要勉强从候选菜品里凑推荐，recommendations 返回空数组，并在 summary 里说明你只能帮忙推荐菜品。
            但如果用户确实是在提食物类需求，只是候选菜品里没有完全对应的选项（比如要披萨但菜单没有），
            不要返回空数组——诚实说明没有完全匹配的选项，并从候选里挑选相对合适的替代菜品推荐。
            结合用户的需求（口味、预算等）挑选最合适的 1 到 5 个菜品，
            用简体中文写一段简短的总体推荐语（summary），并为每个推荐的菜品写一句推荐理由（reason）。
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
            throw new IllegalArgumentException("请输入你的点餐需求");
        }

        List<MenuItemSearchResultDto> candidates = aiSearchService.search(userMessage, CANDIDATE_LIMIT);

        String candidateText = candidates.stream()
                .map(item -> "ID:%d 名称:%s 价格:%.2f 描述:%s".formatted(
                        item.id(), item.name(), item.price(), item.description()))
                .collect(Collectors.joining("\n"));

        String userPrompt = "候选菜品列表：\n" + candidateText + "\n\n用户需求：" + userMessage;

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
