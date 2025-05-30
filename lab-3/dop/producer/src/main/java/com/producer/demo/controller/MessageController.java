package com.producer.demo.controller;

import com.producer.demo.PulsarProducerService;
import com.producer.demo.model.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    private final PulsarProducerService producerService;

    @Autowired
    public MessageController(PulsarProducerService producerService) {
        this.producerService = producerService;
    }

    @PostMapping
    public ResponseEntity<String> sendMessage(@RequestBody Message message) {
        producerService.sendMessage(message);
        return ResponseEntity.ok("Message sent to Pulsar successfully!");
    }
}
