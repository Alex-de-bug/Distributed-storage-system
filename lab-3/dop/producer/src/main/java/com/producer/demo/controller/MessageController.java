package com.producer.demo.controller;

import com.producer.demo.dto.Message;
import com.producer.demo.service.PulsarProducerService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
public class MessageController {

    private final PulsarProducerService producerService;

    @PostMapping
    public ResponseEntity<String> sendMessage(@RequestBody Message message) {
        producerService.sendMessage(message);
        return ResponseEntity.ok("Message sent to Pulsar successfully!");
    }

}
