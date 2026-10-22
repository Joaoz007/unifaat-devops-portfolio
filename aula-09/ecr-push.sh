#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION="${AWS_REGION:-us-east-1}"
ECR_REPOSITORY="${ECR_REPOSITORY:-technova-api}"

for command in aws docker git; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "ERRO: ferramenta obrigatória não encontrada: $command" >&2
    exit 1
  fi
done

ACCOUNT_ID="$(aws sts get-caller-identity \
  --region "$AWS_REGION" \
  --query Account --output text)"

REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE="${REGISTRY}/${ECR_REPOSITORY}"

if DESCRIBE_ERROR="$(aws ecr describe-repositories \
  --repository-names "$ECR_REPOSITORY" \
  --region "$AWS_REGION" 2>&1)"; then
  echo "Repositório ECR já existe: $ECR_REPOSITORY"
else
  if grep -q "RepositoryNotFoundException" <<< "$DESCRIBE_ERROR"; then
    echo "Criando repositório ECR: $ECR_REPOSITORY"
    aws ecr create-repository \
      --repository-name "$ECR_REPOSITORY" \
      --region "$AWS_REGION" >/dev/null
  else
    echo "ERRO ao consultar o repositório ECR:" >&2
    printf '%s\n' "$DESCRIBE_ERROR" >&2
    exit 1
  fi
fi

aws ecr get-login-password --region "$AWS_REGION" |
  docker login --username AWS --password-stdin "$REGISTRY"

SHORT_SHA="$(git rev-parse --short=7 HEAD)"
IMAGE_SHA="${IMAGE}:sha-${SHORT_SHA}"

docker build \
  -t "$IMAGE_SHA" \
  -t "${IMAGE}:latest" \
  .

docker push "$IMAGE_SHA"
docker push "${IMAGE}:latest"

VERSION_TAG="$(git describe --tags --exact-match HEAD 2>/dev/null || true)"

if [[ "$VERSION_TAG" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  VERSION="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  MINOR="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
  MAJOR="${BASH_REMATCH[1]}"

  docker tag "$IMAGE_SHA" "${IMAGE}:${VERSION}"
  docker tag "$IMAGE_SHA" "${IMAGE}:${MINOR}"
  docker tag "$IMAGE_SHA" "${IMAGE}:${MAJOR}"

  docker push "${IMAGE}:${VERSION}"
  docker push "${IMAGE}:${MINOR}"
  docker push "${IMAGE}:${MAJOR}"
else
  echo "Nenhuma tag Git vMAJOR.MINOR.PATCH encontrada no commit atual."
  echo "Publicadas somente as tags sha-${SHORT_SHA} e latest."
fi

echo "Publicação concluída: ${IMAGE}"
