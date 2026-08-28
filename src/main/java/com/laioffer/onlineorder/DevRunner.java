package com.laioffer.onlineorder;


import com.laioffer.onlineorder.service.CustomerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;


@Component
public class DevRunner implements ApplicationRunner {


    private static final Logger logger = LoggerFactory.getLogger(DevRunner.class);


    private final CustomerService customerService;
    private final JdbcTemplate jdbcTemplate;


    public DevRunner(
            CustomerService customerService,
            JdbcTemplate jdbcTemplate) {
        this.customerService = customerService;
        this.jdbcTemplate = jdbcTemplate;
    }


    @Override
    public void run(ApplicationArguments args) throws Exception {
        customerService.signUp("foo@mail.com", "123456", "Foo", "Bar");
        // 本地开发用种子账号：foo@mail.com 同时具备 ROLE_ADMIN，方便联调管理员接口。
        jdbcTemplate.update("INSERT INTO authorities (email, authority) VALUES (?, ?)", "foo@mail.com", "ROLE_ADMIN");
    }
}
