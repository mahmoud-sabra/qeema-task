package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloVersionController {
    
    @GetMapping("/")
    public String hello() {
        return "hello from version 1.0.1";
    }
    
    @GetMapping("/version")
    public String version() {
        return "hello from version 1.0.1";
    }
}
