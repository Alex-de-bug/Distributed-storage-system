package com.producer.demo.util;

import org.mapstruct.Mapper;

import com.producer.demo.dto.Message;
import com.producer.demo.dto.TopicMessage;

@Mapper(componentModel = "spring")
public interface MessageMapper {
    TopicMessage toTopicMessage(Message message);
}
