graph TD
    C[Client] --> G[Gateway Service]
    G -->|AuthZ Lib| H[Hazelcast/Redis Cache 5min]
    G --> A[AuthN Service]
    A --> U[User Service]
    A -->|Session Tracking| R[Redis 7d TTL]
    
    subgraph AuthN Flow
        A -->|JWT Generation| C
        A -->|Session Management| R
    end
    
    subgraph AuthZ Flow
        G -->|Token Verification| A
        G -->|Claims Caching| H
    end
    
    subgraph Data Services
        U --> DB[(User DB)]
    end