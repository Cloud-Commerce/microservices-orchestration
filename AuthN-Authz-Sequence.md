%% Authentication and Authorization Architecture for eCommerce Retail
sequenceDiagram
    participant C as Client
    participant G as Gateway Service
    participant A as AuthN Service
    participant U as User Service
    participant R as Redis
    participant H as Hazelcast/Gateway Cache

    %% Signup Flow
    C->>G: POST /signup (user details)
    G->>A: Forward signup request
    A->>U: Create user request
    U-->>A: User created
    A-->>G: Signup success
    G-->>C: 201 Created

    %% Login Flow
    C->>G: POST /login (credentials)
    G->>A: Forward login request
    A->>U: Get user details
    U-->>A: User details + permissions
    A->>A: Generate JWT (15min TTL)
    A->>R: Set active session (7d TTL)
    A-->>G: JWT response
    G-->>C: 200 OK + JWT

    %% Regular Request Flow
    C->>G: Request with JWT
    alt Cached in H
        G->>H: Get cached claims
        H-->>G: Return claims
    else Not cached
        G->>A: Verify token
        A->>R: Check active session
        R-->>A: Session valid
        A->>R: Reset TTL (7d)
        A-->>G: Claims
        G->>H: Cache claims (5min)
    end
    G->>Downstream: Forward request
    Downstream-->>G: Response
    G-->>C: Return response

    %% Token Refresh Flow
    C->>G: Expired JWT
    G->>A: Verify with client metadata
    alt Metadata matches
        A->>A: Generate new JWT
        A->>R: Update session
        A-->>G: New JWT
        G-->>C: 200 + New JWT
    else Metadata mismatch
        A-->>G: 401 Unauthorized
        G-->>C: Force re-login
    end

    %% Logout Flow
    C->>G: POST /logout
    G->>A: Invalidate token
    A->>R: Delete session
    A->>G: Notification
    G->>H: Invalidate cache
    G-->>C: 200 OK

    %% Password Change Flow
    C->>G: PUT /change-password
    G->>A: Verify token
    A->>R: Find all user sessions
    A->>R: Delete all sessions
    A->>G: Notification
    G->>H: Bulk cache invalidation
    G-->>C: 200 OK