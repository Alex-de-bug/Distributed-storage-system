package com.demo.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "messages")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(columnDefinition = "TEXT")
    private String content;
    
    private String author;
    
    @Column(name = "received_timestamp")
    private LocalDateTime timestamp;
    
    @Column(name = "partition_id")
    private Integer partitionId;
    
    @Column(name = "region")
    private String region;
    
    @Column(name = "processed_at")
    private LocalDateTime processedAt;
    
    @Column(name = "consumer_instance")
    private String consumerInstance;
}
