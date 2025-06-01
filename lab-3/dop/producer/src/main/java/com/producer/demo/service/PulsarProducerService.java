package com.producer.demo.service;

import org.apache.pulsar.client.api.Producer;
import org.apache.pulsar.client.api.PulsarClient;
import org.apache.pulsar.client.api.PulsarClientException;
import org.apache.pulsar.client.api.Schema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.producer.demo.dto.Message;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class PulsarProducerService {

    @Value("${pulsar.service-url}")
    private String pulsarServiceUrl;

    @Value("${pulsar.topic.ru}")
    private String topicRu;

    @Value("${pulsar.topic.eu}")
    private String topicEu;

    private PulsarClient client;
    private Producer<Message> producerRu;
    private Producer<Message> producerEu;

    @PostConstruct
    public void init() throws PulsarClientException {
        client = PulsarClient.builder()
                .serviceUrl(pulsarServiceUrl)
                .build();

        producerRu = client.newProducer(Schema.JSON(Message.class))
                .topic(topicRu)
                .create();

        log.info("Pulsar producer initialized for topic: {}", topicRu);

        producerEu = client.newProducer(Schema.JSON(Message.class))
                .topic(topicEu)
                .create();

        log.info("Pulsar producer initialized for topic: {}", topicEu);
        
    }

    public void sendMessage(Message message) {
        try {
            switch (message.getRegion().toLowerCase()) {
                case "ru":
                    producerRu.send(message);
                    break;
                case "eu":
                    producerEu.send(message);
                    break;
                default:
                    log.error("Invalid region: {}", message.getRegion());
                    break;
            }
            log.info("Message sent: {}", message);
        } catch (PulsarClientException e) {
            log.error("Failed to send message to Pulsar", e);
            throw new RuntimeException("Failed to send message to Pulsar", e);
        }
    }

    @PreDestroy
    public void cleanup() {
        if (producerRu != null) {
            try {
                producerRu.close();
            } catch (PulsarClientException e) {
                log.error("Error closing producer ru", e);
            }
        }
        if (producerEu != null) {
            try {
                producerEu.close();
            } catch (PulsarClientException e) {
                log.error("Error closing producer eu", e);
            }
        }
        if (client != null) {
            try {
                client.close();
            } catch (PulsarClientException e) {
                log.error("Error closing client", e);
            }
        }
    }
}
