package com.demo.service;

import com.demo.config.ConsumerProperties;
import com.demo.dao.MessageRepository;
import com.demo.dto.TopicMessage;
import com.demo.entity.MessageEntity;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pulsar.client.api.*;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.time.LocalDateTime;
import java.util.concurrent.atomic.AtomicLong;

@Slf4j
@Service
@RequiredArgsConstructor
public class PulsarConsumerService {

    private final MessageRepository messageRepository;
    private final ObjectMapper objectMapper;
    private final ConsumerProperties consumerProperties;

    private PulsarClient client;
    private Consumer<byte[]> consumer;
    private final AtomicLong processedMessages = new AtomicLong(0);

    @PostConstruct
    public void init() throws PulsarClientException {
        client = PulsarClient.builder()
                .serviceUrl(consumerProperties.getServiceUrl())
                .build();

        String topicName = consumerProperties.getTopic();
        
        consumer = client.newConsumer()
                .topic(topicName)
                .subscriptionName(consumerProperties.getSubscriptionName())
                .subscriptionType(SubscriptionType.Shared)
                .messageListener(this::handleMessage)
                .subscribe();

        log.info("Pulsar consumer initialized - Region: {}, Instance: {}, Topic: {}, Subscription: {}", 
                consumerProperties.getRegion(), 
                consumerProperties.getInstanceId(),
                topicName, 
                consumerProperties.getSubscriptionName());
    }

    private void handleMessage(Consumer<byte[]> consumer, Message<byte[]> msg) {
        try {
            TopicMessage topicMessage = objectMapper.readValue(msg.getData(), TopicMessage.class);
            
            MessageEntity message = new MessageEntity();
            message.setContent(topicMessage.getContent());
            message.setAuthor(topicMessage.getAuthor());
            message.setTimestamp(topicMessage.getTimestamp());
            message.setPartitionId(extractPartitionId(msg));
            message.setRegion(consumerProperties.getRegion());
            message.setConsumerInstance(consumerProperties.getConsumerInstanceName());
            message.setProcessedAt(LocalDateTime.now());

            messageRepository.save(message);
            log.debug("Message saved to database with ID: {}", message.getId());
            consumer.acknowledge(msg);
            
            long count = processedMessages.incrementAndGet();

            log.info("Message counter: {}", count);
            log.info("Message #{} processed - Region: {}, Instance: {}, Partition: {}, Author: {}", 
                    count, message.getRegion(), message.getConsumerInstance(), 
                    message.getPartitionId(), message.getAuthor());
        } catch (Exception e) {
            log.error("Error processing message: {}", e.getMessage(), e);
            consumer.negativeAcknowledge(msg);
        }
    }

    private Integer extractPartitionId(Message<byte[]> msg) {
        try {
            String topicName = msg.getTopicName();
            if (topicName.contains("-partition-")) {
                String partitionPart = topicName.substring(topicName.lastIndexOf("-partition-") + 11);
                return Integer.parseInt(partitionPart);
            }
            return 0;
        } catch (Exception e) {
            log.warn("Could not extract partition ID from topic: {}", msg.getTopicName());
            return 0;
        }
    }

    public long getProcessedMessagesCount() {
        return processedMessages.get();
    }

    @PreDestroy
    public void cleanup() {
        if (consumer != null) {
            try {
                consumer.close();
                log.info("Consumer closed - processed {} messages", processedMessages.get());
            } catch (PulsarClientException e) {
                log.error("Error closing consumer", e);
            }
        }
        if (client != null) {
            try {
                client.close();
                log.info("Pulsar client closed");
            } catch (PulsarClientException e) {
                log.error("Error closing client", e);
            }
        }
    }
}
