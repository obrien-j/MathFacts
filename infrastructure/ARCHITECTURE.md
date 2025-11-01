# MathFacts Azure Architecture - Security Best Practices

## Overview

This document outlines the Azure architecture for the MathFacts learning app, designed with security best practices and Canadian data residency requirements.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        User (Web Browser)                        │
└──────────────┬──────────────────────────────────┬───────────────┘
               │                                   │
               │ HTTPS Only                        │ HTTPS Only
               │                                   │
               ▼                                   ▼
┌──────────────────────────┐          ┌──────────────────────────┐
│  Azure Static Web Apps   │          │    Azure AD B2C Tenant   │
│  (Flutter Web App)       │          │    (Authentication)      │
│  Location: Central US*   │◄─────────┤    Location: Canada**    │
│  • HTTPS enforced        │   Token  │    • OAuth 2.0/OIDC      │
│  • CDN distribution      │          │    • MFA capable         │
└──────────────┬───────────┘          └──────────────────────────┘
               │
               │ HTTPS + Bearer Token
               │ CORS: Restricted origins
               ▼
┌────────────────────────────────────────────────────────────────┐
│              Azure Functions (Consumption Plan)                 │
│              Location: Canada Central                           │
│              • HTTPS only (TLS 1.2+)                           │
│              • Managed Identity enabled                         │
│              • CORS restricted                                  │
│              • Remote debugging disabled                        │
│              • Token validation on every request                │
└─────────────┬─────────────────────────────┬───────────────────┘
              │                              │
              │ Managed Identity             │ Managed Identity
              │ RBAC: Table Data Contributor │ RBAC: Secrets User
              ▼                              ▼
┌──────────────────────────┐    ┌────────────────────────────────┐
│  Azure Table Storage     │    │     Azure Key Vault            │
│  Location: Canada Central│    │     Location: Canada Central   │
│  • HTTPS only (TLS 1.2+) │    │     • Soft delete enabled      │
│  • No public access      │    │     • RBAC enabled             │
│  • Network: Deny by def. │    │     • Network: Deny by default │
│  • Infrastructure encrypt│    │     • Audit logging            │
└──────────────────────────┘    └────────────────────────────────┘
              │
              │ Telemetry (HTTPS)
              ▼
┌──────────────────────────┐
│  Application Insights    │
│  Location: Canada Central│
│  • Encrypted in transit  │
│  • Encrypted at rest     │
└──────────────────────────┘

* Static Web Apps CDN edge locations globally, but managed from Central US
** Azure AD B2C can be configured with Canadian data residency preferences
```

## Core Components

### 1. Azure Static Web Apps
**Purpose**: Host the Flutter web application  
**Location**: Central US (management) with global CDN  
**Security Features**:
- ✅ Automatic HTTPS/TLS encryption
- ✅ Global CDN with DDoS protection
- ✅ Custom domain support with free SSL
- ✅ Built-in authentication integration

**Note**: Static Web Apps doesn't have Canada region yet, but the static assets are cached globally via CDN for performance. Backend API calls go to Canada.

### 2. Azure Functions (Consumption Plan)
**Purpose**: Serverless backend API for authenticated operations  
**Location**: Canada Central  
**Security Features**:
- ✅ **HTTPS Only**: TLS 1.2+ required
- ✅ **Managed Identity**: No credentials in code
- ✅ **RBAC**: Role-based access to resources
- ✅ **CORS**: Restricted to specific origins
- ✅ **Token Validation**: Verifies Azure AD B2C tokens
- ✅ **No Remote Debugging**: Disabled in production
- ✅ **HTTP/2**: Enabled for performance
- ✅ **FTP**: Disabled

**API Endpoints** (planned):
- `GET /api/progress` - Retrieve user progress (requires auth token)
- `POST /api/progress` - Save user progress (requires auth token)

### 3. Azure Table Storage
**Purpose**: Store user progress and MathFact performance data  
**Location**: Canada Central  
**Security Features**:
- ✅ **HTTPS Only**: All connections require TLS
- ✅ **TLS 1.2 Minimum**: Modern encryption standards
- ✅ **No Public Access**: Blob public access disabled
- ✅ **Infrastructure Encryption**: Double encryption at rest
- ✅ **Network Rules**: Deny by default, Azure Services only
- ✅ **Managed Identity Access**: Functions use RBAC, not keys
- ✅ **Data Residency**: All data stays in Canada

**Data Schema** (planned):
```
Table: userprogress
PartitionKey: userId (from B2C token)
RowKey: factId (e.g., "add-3-4")
Properties:
  - operand1: int
  - operand2: int
  - operation: string
  - attempts: int
  - correctCount: int
  - lastPracticed: timestamp
  - masteryLevel: int
```

### 4. Azure Key Vault
**Purpose**: Securely store secrets, keys, and certificates  
**Location**: Canada Central  
**Security Features**:
- ✅ **RBAC Authorization**: Fine-grained access control
- ✅ **Soft Delete**: 7-day retention for recovery
- ✅ **Network ACLs**: Deny by default
- ✅ **Audit Logging**: All access logged
- ✅ **Managed Identity Access**: Functions use RBAC
- ✅ **Encryption**: All secrets encrypted at rest

**Secrets Stored**:
- Azure AD B2C configuration
- Storage connection strings (backup)
- Third-party API keys (future)

### 5. Application Insights
**Purpose**: Application monitoring, logging, and telemetry  
**Location**: Canada Central  
**Security Features**:
- ✅ **Encrypted in Transit**: HTTPS/TLS
- ✅ **Encrypted at Rest**: Azure storage encryption
- ✅ **Data Retention**: Configurable (default 90 days)
- ✅ **Role-Based Access**: Azure RBAC

### 6. Azure AD B2C
**Purpose**: User authentication and identity management  
**Location**: Configurable (prefer Canada)  
**Security Features**:
- ✅ **OAuth 2.0 / OpenID Connect**: Industry standards
- ✅ **Multi-Factor Authentication**: Optional MFA
- ✅ **Password Policies**: Configurable complexity
- ✅ **Brute Force Protection**: Built-in
- ✅ **Audit Logs**: All auth events logged
- ✅ **GDPR Compliant**: Data privacy controls

## Security Architecture Principles

### 1. **Data Residency: Canada Only**
- ✅ All compute and storage in Canada Central or Canada East
- ✅ Exception: Static Web App CDN (global for performance)
- ✅ User data never leaves Canadian datacenters

### 2. **Zero Trust Architecture**
- ✅ Every request authenticated and authorized
- ✅ No implicit trust between components
- ✅ Managed Identities instead of credentials
- ✅ Network segmentation (deny by default)

### 3. **Defense in Depth**
- ✅ **Layer 1**: HTTPS/TLS encryption everywhere
- ✅ **Layer 2**: Azure AD B2C authentication
- ✅ **Layer 3**: Function App validates tokens
- ✅ **Layer 4**: RBAC controls resource access
- ✅ **Layer 5**: Network rules restrict connectivity
- ✅ **Layer 6**: Audit logging for compliance

### 4. **Least Privilege Access**
- ✅ Managed Identities use specific RBAC roles
- ✅ No shared secrets or connection strings in code
- ✅ Key Vault for centralized secret management
- ✅ Time-limited access tokens

### 5. **Encryption Everywhere**
- ✅ **In Transit**: TLS 1.2+ for all connections
- ✅ **At Rest**: Azure Storage encryption + infrastructure encryption
- ✅ **Key Management**: Azure-managed keys (option for customer-managed)

### 6. **Monitoring & Compliance**
- ✅ Application Insights for real-time monitoring
- ✅ Azure AD audit logs for authentication events
- ✅ Key Vault access logs
- ✅ Storage account diagnostic logs (configurable)

## Authentication Flow

```
1. User opens Flutter web app
   └─> Static Web App serves application

2. User clicks "Sign In"
   └─> Redirected to Azure AD B2C login page

3. User enters credentials
   └─> B2C validates and issues JWT token
   └─> Token contains: userId, email, expiration

4. Flutter app stores token (secure storage)
   └─> Includes token in Authorization header for API calls

5. API request to Azure Functions
   └─> GET /api/progress
   └─> Header: Authorization: Bearer <token>

6. Function validates token
   ├─> Verify signature (B2C public key)
   ├─> Check expiration
   ├─> Extract userId from claims
   └─> If invalid: Return 401 Unauthorized

7. Function accesses Table Storage
   └─> Uses Managed Identity (no credentials)
   └─> Queries data for specific userId only
   └─> RBAC: Storage Table Data Contributor role

8. Function returns data
   └─> Response sent over HTTPS
   └─> User data isolated by userId

9. Token expiration
   └─> Frontend detects 401 response
   └─> Redirects to B2C for refresh/re-login
```

## Network Security

### Firewall Rules

**Storage Account**:
- Default Action: **Deny**
- Allowed: Azure Services (for Functions access)
- Management IPs: Add specific IPs in tfvars for admin access

**Key Vault**:
- Default Action: **Deny**
- Allowed: Azure Services
- Management IPs: Add specific IPs in tfvars for admin access

**Function App**:
- CORS: Restricted to Static Web App origin
- HTTPS Only: Port 443 only
- FTP: Disabled

### Private Endpoints (Future Enhancement)

For production with higher security requirements:
- ✅ Azure Functions can use VNet integration
- ✅ Storage Account private endpoints
- ✅ Key Vault private endpoints
- ✅ All traffic stays within Azure backbone

**Cost Impact**: Requires higher service tiers (~$50-100/month additional)

## Compliance & Data Governance

### Data Classification
- **User Credentials**: Managed by Azure AD B2C (not stored by us)
- **User Progress Data**: PII (contains userId), encrypted at rest
- **Telemetry Data**: No PII, aggregated metrics only

### Regulatory Compliance
- ✅ **Canadian Data Residency**: All data in Canada regions
- ✅ **GDPR Ready**: User data deletion supported
- ✅ **PIPEDA**: Personal Information Protection (Canada)

### Data Retention
- **Table Storage**: Indefinite (until user deletion requested)
- **Application Insights**: 90 days default
- **Key Vault Soft Delete**: 7 days retention
- **Audit Logs**: 90 days (configurable)

## Cost Optimization

All services use consumption/free tiers for cost efficiency:

| Service | Tier | Estimated Monthly Cost |
|---------|------|----------------------|
| Static Web App | Free | $0 |
| Azure Functions | Consumption | $0 (1M free executions) |
| Table Storage | Standard LRS | $0.10-1 |
| Key Vault | Standard | $0.03 per 10K operations (~$0-1) |
| Application Insights | Free | $0 (5GB free) |
| Azure AD B2C | Free | $0 (50K auths/month) |
| **Total** | | **~$0-3/month** |

## Security Roadmap

### Phase 1: Foundation (Current)
- ✅ HTTPS everywhere
- ✅ Managed Identities
- ✅ Azure AD B2C authentication
- ✅ RBAC for resource access
- ✅ Network rules (deny by default)
- ✅ Key Vault for secrets

### Phase 2: Enhanced Security (Future)
- ⏳ Enable Azure AD Conditional Access
- ⏳ Implement rate limiting on Functions
- ⏳ Add WAF (Web Application Firewall) for Static Web App
- ⏳ Enable MFA requirement for all users
- ⏳ Advanced threat protection for Storage

### Phase 3: Enterprise Security (Future)
- ⏳ VNet integration with private endpoints
- ⏳ Customer-managed encryption keys
- ⏳ Azure DDoS Protection Standard
- ⏳ Azure Security Center recommendations
- ⏳ Penetration testing

## Disaster Recovery & Business Continuity

### Backup Strategy
- **Table Storage**: LRS (3 copies in Canada Central)
- **Option**: Enable GRS for geo-redundant backup to Canada East
- **Key Vault**: Soft delete (7-day recovery window)
- **Infrastructure**: Terraform state backed up

### Recovery Objectives
- **RTO** (Recovery Time Objective): < 1 hour
- **RPO** (Recovery Point Objective): < 5 minutes (table storage replication)

### Recovery Procedures
1. Re-deploy infrastructure via Terraform
2. Restore Key Vault secrets (soft delete recovery)
3. Table Storage data survives (unless storage account deleted)
4. Re-deploy Function App code from Git
5. Update DNS/endpoints if needed

## Monitoring & Alerting

### Key Metrics to Monitor
- ✅ Function execution failures
- ✅ Authentication failures (401/403 responses)
- ✅ API response times
- ✅ Storage throttling events
- ✅ Key Vault access anomalies

### Alerting Rules (Future)
- Error rate > 5% for 5 minutes
- Authentication failures > 100/hour
- Average response time > 2 seconds
- Storage account throttling detected

## References

- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
- [Azure Functions Security](https://docs.microsoft.com/en-us/azure/azure-functions/security-concepts)
- [Azure Storage Security](https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide)
- [Azure AD B2C Best Practices](https://docs.microsoft.com/en-us/azure/active-directory-b2c/best-practices)
- [Canadian Data Residency](https://azure.microsoft.com/en-ca/explore/global-infrastructure/geographies/#geographies)

---

**Last Updated**: October 31, 2025  
**Architecture Version**: 1.0  
**Security Review**: Required before production deployment
