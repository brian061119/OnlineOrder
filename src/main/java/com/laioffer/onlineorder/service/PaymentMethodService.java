package com.laioffer.onlineorder.service;


import com.laioffer.onlineorder.entity.PaymentMethodEntity;
import com.laioffer.onlineorder.model.AddPaymentMethodBody;
import com.laioffer.onlineorder.model.PaymentMethodDto;
import com.laioffer.onlineorder.repository.PaymentMethodRepository;
import org.springframework.stereotype.Service;


import java.util.List;


@Service
public class PaymentMethodService {


    private final PaymentMethodRepository paymentMethodRepository;


    public PaymentMethodService(PaymentMethodRepository paymentMethodRepository) {
        this.paymentMethodRepository = paymentMethodRepository;
    }


    public List<PaymentMethodDto> getPaymentMethods(long customerId) {
        return paymentMethodRepository.findByCustomerId(customerId).stream()
                .map(PaymentMethodDto::new)
                .toList();
    }


    public PaymentMethodDto addPaymentMethod(long customerId, AddPaymentMethodBody body) {
        String digitsOnly = body.cardNumber().replaceAll("[\\s-]", "");
        if (!digitsOnly.matches("\\d{12,19}")) {
            throw new IllegalArgumentException("Invalid card number");
        }
        String brand = detectBrand(digitsOnly);
        String lastFour = digitsOnly.substring(digitsOnly.length() - 4);
        PaymentMethodEntity entity = new PaymentMethodEntity(
                null, customerId, body.cardHolder(), brand, lastFour, body.expiryMonth(), body.expiryYear());
        return new PaymentMethodDto(paymentMethodRepository.save(entity));
    }


    // 卡号只用来一次性判断卡组织和取末四位，判断完就丢弃，不落库存储完整卡号。
    private String detectBrand(String digitsOnly) {
        if (digitsOnly.startsWith("4")) {
            return "Visa";
        }
        if (digitsOnly.startsWith("34") || digitsOnly.startsWith("37")) {
            return "Amex";
        }
        if (digitsOnly.startsWith("6")) {
            return "Discover";
        }
        int prefix = Integer.parseInt(digitsOnly.substring(0, 2));
        if (prefix >= 51 && prefix <= 55) {
            return "Mastercard";
        }
        return "Card";
    }
}
