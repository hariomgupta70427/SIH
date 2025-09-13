#!/bin/bash
# Deployment script for Railway Parts Management System

set -e  # Exit on any error

# Configuration
PROJECT_NAME="railway-parts"
DOCKER_COMPOSE_FILE="deployment/docker/docker-compose.yml"
ENV_FILE=".env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed"
    fi
    
    # Check environment file
    if [ ! -f "$ENV_FILE" ]; then
        warn "Environment file not found, creating from template..."
        cp .env.example "$ENV_FILE"
        warn "Please update $ENV_FILE with your configuration"
    fi
    
    log "Prerequisites check completed"
}

# Build Docker images
build_images() {
    log "Building Docker images..."
    
    # Build backend image
    docker build -f deployment/docker/Dockerfile.backend -t ${PROJECT_NAME}-backend .
    
    # Build frontend image
    docker build -f deployment/docker/Dockerfile.flutter -t ${PROJECT_NAME}-frontend .
    
    log "Docker images built successfully"
}

# Deploy services
deploy_services() {
    log "Deploying services..."
    
    # Stop existing services
    docker-compose -f "$DOCKER_COMPOSE_FILE" down
    
    # Start services
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    
    # Wait for services to be healthy
    log "Waiting for services to be ready..."
    sleep 30
    
    # Check service health
    check_service_health
    
    log "Services deployed successfully"
}

# Check service health
check_service_health() {
    log "Checking service health..."
    
    # Check database
    if ! docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T database pg_isready -U postgres; then
        error "Database is not ready"
    fi
    
    # Check backend API
    if ! curl -f http://localhost:3000/health > /dev/null 2>&1; then
        error "Backend API is not responding"
    fi
    
    # Check frontend
    if ! curl -f http://localhost/ > /dev/null 2>&1; then
        error "Frontend is not responding"
    fi
    
    log "All services are healthy"
}

# Seed database
seed_database() {
    log "Seeding database with sample data..."
    
    # Run seeding script inside backend container
    docker-compose -f "$DOCKER_COMPOSE_FILE" exec backend npm run seed
    
    log "Database seeded successfully"
}

# Run tests
run_tests() {
    log "Running integration tests..."
    
    # Run API tests
    docker-compose -f "$DOCKER_COMPOSE_FILE" exec backend npm run test:api
    
    log "Tests completed successfully"
}

# Backup database
backup_database() {
    log "Creating database backup..."
    
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T database pg_dump -U postgres inventory_db > "$BACKUP_FILE"
    
    log "Database backup created: $BACKUP_FILE"
}

# Show logs
show_logs() {
    docker-compose -f "$DOCKER_COMPOSE_FILE" logs -f
}

# Show status
show_status() {
    log "Service Status:"
    docker-compose -f "$DOCKER_COMPOSE_FILE" ps
    
    log "Resource Usage:"
    docker stats --no-stream
}

# Cleanup
cleanup() {
    log "Cleaning up..."
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes
    docker volume prune -f
    
    log "Cleanup completed"
}

# Main deployment function
deploy() {
    log "Starting deployment of $PROJECT_NAME..."
    
    check_prerequisites
    build_images
    deploy_services
    seed_database
    run_tests
    
    log "Deployment completed successfully!"
    log "Services are available at:"
    log "  - Frontend: http://localhost"
    log "  - Admin Dashboard: http://localhost:8080"
    log "  - API: http://localhost:3000"
    log "  - Database: localhost:5432"
}

# Parse command line arguments
case "${1:-deploy}" in
    "deploy")
        deploy
        ;;
    "build")
        check_prerequisites
        build_images
        ;;
    "start")
        docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
        ;;
    "stop")
        docker-compose -f "$DOCKER_COMPOSE_FILE" down
        ;;
    "restart")
        docker-compose -f "$DOCKER_COMPOSE_FILE" restart
        ;;
    "logs")
        show_logs
        ;;
    "status")
        show_status
        ;;
    "seed")
        seed_database
        ;;
    "test")
        run_tests
        ;;
    "backup")
        backup_database
        ;;
    "cleanup")
        cleanup
        ;;
    "help")
        echo "Usage: $0 [command]"
        echo "Commands:"
        echo "  deploy   - Full deployment (default)"
        echo "  build    - Build Docker images"
        echo "  start    - Start services"
        echo "  stop     - Stop services"
        echo "  restart  - Restart services"
        echo "  logs     - Show service logs"
        echo "  status   - Show service status"
        echo "  seed     - Seed database"
        echo "  test     - Run tests"
        echo "  backup   - Backup database"
        echo "  cleanup  - Clean up unused resources"
        echo "  help     - Show this help"
        ;;
    *)
        error "Unknown command: $1. Use 'help' for available commands."
        ;;
esac