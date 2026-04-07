# CI/CD Pipeline SysML Diagrams

This document contains SysML diagrams documenting the documentation deployment pipeline using Cloudflare R2, Workers, Jenkins, and Dagger CI/CD with native secret management.

## 1. Block Definition Diagram (BDD)

The BDD shows the hierarchical block structure of the documentation pipeline.

```mermaid
classDiagram
    class DocsPipeline {
        +sourceCode()
        +buildDocs()
        +deployStorage()
        +serveContent()
    }
    class GitHub {
        +repository
        +secrets
        +webhook
    }
    class GitHubSecrets {
        +CLOUDFLARE_ACCOUNT_ID
        +CLOUDFLARE_API_TOKEN
    }
    class Jenkins {
        +credentials
        +environment()
        +trigger()
    }
    class Dagger {
        +Secret type
        +pipeline
        +container
    }
    class DaggerModule {
        +Deploy()
        +Build()
    }
    class MkDocs {
        +sourceFiles
        +build()
    }
    class CloudflareR2 {
        +bucket
        +objects
    }
    class CloudflareWorker {
        +r2Binding
        +serveHTML()
    }
    DocsPipeline *-- GitHub
    DocsPipeline *-- GitHubSecrets
    DocsPipeline *-- Jenkins
    DocsPipeline *-- Dagger
    DocsPipeline *-- DaggerModule
    DocsPipeline *-- MkDocs
    DocsPipeline *-- CloudflareR2
    DocsPipeline *-- CloudflareWorker
    Jenkins ..> GitHubSecrets : references
    DaggerModule --|> Dagger : extends
```

## 2. Internal Block Diagram (IBD)

The IBD shows the internal structure and data flow.

```mermaid
flowchart TB
    subgraph PIPELINE["DocsPipeline"]
        direction TB
        CHECKOUT["Git Checkout"]
        BUILD["MkDocs Build"]
        UPLOAD["Upload to R2"]
        DEPLOY["Deploy Worker"]
    end

    subgraph CONTAINER["Build Container"]
        direction LR
        PYTHON["Python 3.11"]
        CURL["curl"]
        NODE["Node.js"]
        WRangler["Wrangler CLI"]
    end

    subgraph EXTERNAL["External Services"]
        GITHUB["GitHub Repo"]
        R2["R2 Bucket: docs-ops"]
        WORKER["Worker: docs-worker"]
    end

    CHECKOUT --> BUILD
    BUILD --> UPLOAD
    UPLOAD --> DEPLOY

    CHECKOUT ..->|"source code"| GITHUB
    BUILD -->|"site/ directory"| CONTAINER
    UPLOAD -->|"PUT files"| R2
    DEPLOY -->|"wrangler deploy"| WORKER
```

## 3. Sequence Diagram (SD)

The SD shows the deployment flow from commit to live site.

```mermaid
sequenceDiagram
    participant DEV as Developer
    participant GH as GitHub
    participant JK as Jenkins
    participant DG as Dagger
    participant MK as MkDocs
    participant R2 as Cloudflare R2
    participant WR as Cloudflare Worker
    participant USER as End User

    DEV->>GH: Push commit
    GH->>JK: Trigger webhook
    JK->>DG: Run dagger run go run main.go
    Note right of DG: main() reads os.Getenv()
    DG->>MK: Build documentation
    MK-->>DG: site/ directory
    DG->>R2: Upload files with Bearer token
    R2-->>DG: Upload complete
    DG->>WR: Deploy with R2 binding
    WR-->>DG: Deployed
    DG-->>JK: Success

    USER->>WR: Request docs.khangduytran.xyz
    WR->>R2: Get index.html
    R2-->>WR: HTML content
    WR-->>USER: Rendered page
```

## 4. Block Definition Diagram - Dagger Module

```mermaid
classDiagram
    class DaggerClient {
        +Container()
        +Connect()
        +Host()
    }
    class Secret {
        +Plaintext(ctx) string
    }
    class Directory {
        +Host().Directory()
    }
    class Container {
        +From()
        +WithDirectory()
        +WithExec()
        +WithSecretVariable()
        +Sync()
    }
    class DocsDeploy {
        +Deploy(ctx, *Secret, *Secret, string, string, string, *Directory) string
        +Build(ctx, *Directory) *Directory
    }
    DocsDeploy --> DaggerClient : uses
    DaggerClient --> Container : creates
    Container --> Secret : injects via WithSecretVariable
    Container --> Directory : uses
```

## 5. Internal Block Diagram - Secret Flow

```mermaid
flowchart TB
    subgraph GITHUB["GitHubSecrets"]
        GS1["CLOUDFLARE_ACCOUNT_ID"]
        GS2["CLOUDFLARE_API_TOKEN"]
    end

    subgraph JENKINS["Jenkins"]
        CRED["credentials()"]
        ENV["os.Getenv()"]
    end

    subgraph DAGGER["Dagger Pipeline"]
        SECRET["*dagger.Secret"]
        CONTAINER["Container"]
    end

    subgraph CLOUDFLARE["Cloudflare"]
        R2["R2 Bucket"]
        WORKER["Worker"]
    end

    GS1 -->|"credential ID"| CRED
    GS2 -->|"credential ID"| CRED
    CRED -->|"environment"| ENV
    ENV -->|"read"| SECRET
    SECRET -->|"Plaintext()"| CONTAINER
    CONTAINER -->|"curl upload"| R2
    CONTAINER -->|"wrangler deploy"| WORKER
```

## 6. State Diagram

The state diagram shows the lifecycle of a documentation deployment.

```mermaid
stateDiagram-v2
    [*] --> TRIGGERED: Push to GitHub
    TRIGGERED --> CREDENTIALS: Jenkins starts
    CREDENTIALS --> BUILDING: Dagger starts
    BUILDING --> BUILD_SUCCESS: MkDocs complete
    BUILDING --> BUILD_FAILED: Build error
    BUILD_SUCCESS --> UPLOADING: Secret accessed
    UPLOADING --> UPLOAD_SUCCESS: R2 synced
    UPLOADING --> UPLOAD_FAILED: API error
    UPLOAD_SUCCESS --> DEPLOYING: Worker deploy
    DEPLOYING --> DEPLOYED: Wrangler success
    DEPLOYING --> DEPLOY_SKIPPED: Token lacks permissions
    DEPLOYED --> [*]: Live at docs.khangduytran.xyz
    BUILD_FAILED --> [*]: Pipeline failed
    UPLOAD_FAILED --> [*]: Pipeline failed
    DEPLOY_SKIPPED --> [*]: Site accessible
```

## 7. Sequence Diagram - Secret Flow

```mermaid
sequenceDiagram
    participant GH as GitHub Secrets
    participant JK as Jenkins
    participant DG as Dagger
    participant MK as MkDocs
    participant R2 as Cloudflare R2
    participant WR as Cloudflare Worker

    Note over GH,JK: Secret Configuration
    GH->>JK: Store CLOUDFLARE_ACCOUNT_ID
    GH->>JK: Store CLOUDFLARE_API_TOKEN

    Note over JK,DG: Pipeline Execution
    JK->>DG: dagger run go run main.go
    DG->>DG: os.Getenv(R2_ACCOUNT_ID)
    DG->>DG: os.Getenv(CLOUDFLARE_API_TOKEN)
    DG->>MK: Build documentation
    MK-->>DG: site/ directory
    DG->>R2: Upload with Bearer token
    R2-->>DG: 200 OK
    DG->>WR: Deploy with Wrangler
    WR-->>DG: Deployed
```

## 8. Requirement Diagram

System requirements for the documentation pipeline.

```mermaid
flowchart LR
    subgraph REQ["Requirements"]
        R1["R1: Source documentation from Git"]
        R2["R2: Build with MkDocs"]
        R3["R3: Store in R2 bucket"]
        R4["R4: Serve via Worker"]
        R5["R5: Custom domain"]
        R6["R6: HTTPS encryption"]
        R7["R7: Automatic deployment"]
        R8["R8: Secrets from GitHub"]
        R9["R9: Dagger CI/CD"]
        R10["R10: Mermaid diagrams"]
    end
```

## 9. Parametric Diagram

Resource flow showing build and deploy volumes.

```mermaid
flowchart LR
    INPUT["Source Files<br>~50 markdown files"]
    -->
    BUILD["MkDocs Build<br>~3 MB output"]
    -->
    STORAGE["R2 Storage<br>~3 MB total"]
    -->
    SERVED["Cloudflare CDN<br>~3 MB bandwidth"]

    style INPUT fill:#bbf7d0
    style BUILD fill:#fef08a
    style STORAGE fill:#bbf7d0
    style SERVED fill:#93c5fd
```

## 10. Allocation Diagram

Component deployment and configuration allocation.

```mermaid
flowchart TB
    subgraph GITHUB["GitHub Organization"]
        REPO["k8s-audit-security-docs"]
        GS["GitHub Secrets"]
    end

    subgraph JENKINS["Jenkins Server"]
        CRED["Credentials"]
    end

    subgraph CLOUDFLARE["Cloudflare Account"]
        subgraph STORAGE["R2 Storage"]
            R2["docs-ops Bucket"]
        end

        subgraph COMPUTE["Workers & Pages"]
            WORKER["docs-worker"]
        end

        subgraph NETWORK["DNS & CDN"]
            DNS["docs.khangduytran.xyz"]
        end
    end

    REPO -->|"push trigger"| JENKINS
    GS -->|"credential ID"| CRED
    CRED -->|"env vars"| JENKINS
    JENKINS -->|"R2 upload"| R2
    JENKINS -->|"worker deploy"| WORKER
    WORKER -->|"R2 binding"| R2
    DNS -->|"custom domain"| WORKER
```

## 11. Activity Diagram

The AD shows the CI/CD build and deploy process.

```mermaid
flowchart TD
    START([Start])
    START --> GIT["Git Push"]
    GIT --> JK["Jenkins Trigger"]
    JK --> CHECKOUT["Git Checkout"]
    CHECKOUT --> DAGGER["Dagger Run"]
    DAGGER --> ENV["Read os.Getenv()"]
    ENV --> BUILD["MkDocs Build"]
    BUILD --> BUILD_OK{"Build Success?"}
    BUILD_OK -->|No| BUILD_FAIL["Fail"]
    BUILD_OK -->|Yes| SECRET["Get Secret"]
    SECRET --> UPLOAD["Upload to R2"]
    UPLOAD --> UPLOAD_OK{"Upload Success?"}
    UPLOAD_OK -->|No| UPLOAD_FAIL["Fail"]
    UPLOAD_OK -->|Yes| WRANGLER["Deploy Worker"]
    WRANGLER --> WR_OK{"Deploy Success?"}
    WR_OK -->|No| WR_SKIP["Skip"]
    WR_OK -->|Yes| SUCCESS["Success"]
    BUILD_FAIL --> END([End])
    UPLOAD_FAIL --> END
    WR_SKIP --> SUCCESS
    SUCCESS --> END
```

## 12. Communication Diagram - Dual Mode

Shows both Jenkins and CLI usage.

```mermaid
sequenceDiagram
    participant J as Jenkins
    participant CLI as Dagger CLI
    participant D as Dagger Module
    participant C as Container

    Note over J,D: Mode 1: Jenkins with main()
    J->>D: dagger run go run main.go
    Note right of D: main() uses os.Getenv()
    D->>C: Build container

    Note over CLI,D: Mode 2: CLI with module
    CLI->>D: dagger call deploy
    Note right of D: Deploy() uses *Secret
    D->>C: Build container
    C-->>D: Build complete
    D-->>J: Success
    D-->>CLI: Success
```

## 13. Block Definition Diagram - Components

```mermaid
classDiagram
    class GitHubSecrets {
        +CLOUDFLARE_ACCOUNT_ID: String
        +CLOUDFLARE_API_TOKEN: String
    }
    class Jenkins {
        +credentials(): void
        +environment(): void
    }
    class DaggerModule {
        +Deploy(*Secret, *Secret): String
        +Build(*Directory): *Directory
    }
    class MkDocs {
        +sourceFiles: Directory
        +build(): Directory
    }
    class CloudflareR2 {
        +bucket: String
        +upload(): void
    }
    class CloudflareWorker {
        +r2Binding: R2Bucket
        +deploy(): void
    }

    Jenkins ..> GitHubSecrets : uses
    DaggerModule ..> GitHubSecrets : receives
    DaggerModule --> MkDocs : calls
    DaggerModule --> CloudflareR2 : uploads
    DaggerModule --> CloudflareWorker : deploys
```
