package com.producer.demo.model;

import java.time.LocalDateTime;

public class Message {
    private String content;
    private String author;
    private LocalDateTime timestamp;

    // Конструкторы, геттеры, сеттеры
    public Message() {
        this.timestamp = LocalDateTime.now();
    }

    public Message(String content, String author) {
        this.content = content;
        this.author = author;
        this.timestamp = LocalDateTime.now();
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    @Override
    public String toString() {
        return "Message{" +
                "content='" + content + '\'' +
                ", author='" + author + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}
