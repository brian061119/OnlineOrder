package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.entity.OrderEntity;
import com.laioffer.onlineorder.entity.OrderLineItemEntity;
import com.laioffer.onlineorder.entity.PaymentMethodEntity;
import com.laioffer.onlineorder.exception.ResourceNotFoundException;
import com.laioffer.onlineorder.model.CartDto;
import com.laioffer.onlineorder.model.OrderDto;
import com.laioffer.onlineorder.model.OrderLineItemDto;
import com.laioffer.onlineorder.repository.OrderLineItemRepository;
import com.laioffer.onlineorder.repository.OrderRepository;
import com.laioffer.onlineorder.repository.PaymentMethodRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.time.Instant;
import java.util.List;


@Service
public class OrderService {


    private final CartService cartService;
    private final OrderRepository orderRepository;
    private final OrderLineItemRepository orderLineItemRepository;
    private final PaymentMethodRepository paymentMethodRepository;


    public OrderService(
            CartService cartService,
            OrderRepository orderRepository,
            OrderLineItemRepository orderLineItemRepository,
            PaymentMethodRepository paymentMethodRepository) {
        this.cartService = cartService;
        this.orderRepository = orderRepository;
        this.orderLineItemRepository = orderLineItemRepository;
        this.paymentMethodRepository = paymentMethodRepository;
    }


    @Transactional
    public OrderDto checkout(long customerId, long paymentMethodId) {
        PaymentMethodEntity paymentMethod = findOwnedPaymentMethod(customerId, paymentMethodId);

        CartDto cart = cartService.getCart(customerId);
        if (cart.orderItems().isEmpty()) {
            throw new IllegalArgumentException("Cart is empty");
        }

        OrderEntity order = orderRepository.save(new OrderEntity(
                null, customerId, paymentMethod.id(), cart.totalPrice(), "PAID", Instant.now()));

        List<OrderLineItemEntity> lineItems = cart.orderItems().stream()
                .map(item -> new OrderLineItemEntity(
                        null, order.id(), item.menuItemId(), item.menuItemName(), item.price(), item.quantity()))
                .toList();
        orderLineItemRepository.saveAll(lineItems);

        cartService.clearCart(customerId);

        return toOrderDto(order, paymentMethod, lineItems);
    }


    public List<OrderDto> getOrders(long customerId) {
        return orderRepository.findByCustomerIdOrderByCreatedAtDesc(customerId).stream()
                .map(order -> {
                    PaymentMethodEntity paymentMethod = order.paymentMethodId() == null
                            ? null
                            : paymentMethodRepository.findById(order.paymentMethodId()).orElse(null);
                    List<OrderLineItemEntity> lineItems = orderLineItemRepository.findByOrderId(order.id());
                    return toOrderDto(order, paymentMethod, lineItems);
                })
                .toList();
    }


    // 越权校验：payment method 必须属于当前用户自己，跟 CartService.findOwnedOrderItem 是同一套思路。
    private PaymentMethodEntity findOwnedPaymentMethod(long customerId, long paymentMethodId) {
        PaymentMethodEntity paymentMethod = paymentMethodRepository.findById(paymentMethodId).orElse(null);
        if (paymentMethod == null || !paymentMethod.customerId().equals(customerId)) {
            throw new ResourceNotFoundException("Payment method " + paymentMethodId + " not found");
        }
        return paymentMethod;
    }


    private OrderDto toOrderDto(OrderEntity order, PaymentMethodEntity paymentMethod, List<OrderLineItemEntity> lineItems) {
        return new OrderDto(
                order.id(),
                order.totalPrice(),
                order.status(),
                order.createdAt(),
                paymentMethod == null ? null : paymentMethod.brand(),
                paymentMethod == null ? null : paymentMethod.lastFour(),
                lineItems.stream().map(OrderLineItemDto::new).toList());
    }
}
