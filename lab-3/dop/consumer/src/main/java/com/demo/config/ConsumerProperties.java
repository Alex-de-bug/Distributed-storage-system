package com.demo.config;

import lombok.Data;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Data
@Component
public class ConsumerProperties {
    @Value("${consumer.region}")
    private String region;

    @Value("${consumer.instance-id}")
    private String instanceId;

    @Value("${pulsar.service-url}")
    private String serviceUrl;

    @Value("${pulsar.topic}")
    private String topic;

    @Value("${pulsar.subscription.name}")
    private String subscriptionName;
    
    public String getConsumerInstanceName() {
        return String.format("%s-%s", region, instanceId);
    }
}
