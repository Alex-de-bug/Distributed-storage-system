package com.producer.demo;

import com.producer.demo.model.Message;
import org.apache.pulsar.client.api.Producer;
import org.apache.pulsar.client.api.PulsarClient;
import org.apache.pulsar.client.api.PulsarClientException;
import org.apache.pulsar.client.api.Schema;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

@Service
public class PulsarProducerService {

    private static final Logger logger = LoggerFactory.getLogger(PulsarProducerService.class);

    @Value("${pulsar.service-url}")
    private String pulsarServiceUrl;

    @Value("${pulsar.topic}")
    private String topic;

    private PulsarClient client;
    private Producer<Message> producer;

    @PostConstruct
    public void init() throws PulsarClientException {
        client = PulsarClient.builder()
                .serviceUrl(pulsarServiceUrl)
                .build();

        producer = client.newProducer(Schema.JSON(Message.class))
                .topic(topic)
                .create();

        logger.info("Pulsar producer initialized for topic: {}", topic);
    }

    public void sendMessage(Message message) {
        try {
            producer.send(message);
            logger.info("Message sent: {}", message);
        } catch (PulsarClientException e) {
            logger.error("Failed to send message to Pulsar", e);
            throw new RuntimeException("Failed to send message to Pulsar", e);
        }
    }

    @PreDestroy
    public void cleanup() {
        if (producer != null) {
            try {
                producer.close();
            } catch (PulsarClientException e) {
                logger.error("Error closing producer", e);
            }
        }
        if (client != null) {
            try {
                client.close();
            } catch (PulsarClientException e) {
                logger.error("Error closing client", e);
            }
        }
    }
}
