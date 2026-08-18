# Diagrama de flujo CI/CD

## Diagrama visual

<table>
  <tr>
    <td align="center" width="130">
      <img src="https://cdn.simpleicons.org/github/181717" width="58" alt="GitHub"/><br/>
      <strong>GitHub</strong><br/>
      <sub>mike1594/iac-final-app</sub>
    </td>
    <td align="center">&rarr;<br/><sub>push a main</sub></td>
    <td align="center" width="130">
      <img src="https://cdn.simpleicons.org/githubactions/2088FF" width="58" alt="GitHub Actions"/><br/>
      <strong>GitHub Actions</strong><br/>
      <sub>workflow_dispatch / push</sub>
    </td>
    <td align="center">&rarr;<br/><sub>build</sub></td>
    <td align="center" width="130">
      <img src="https://cdn.simpleicons.org/docker/2496ED" width="58" alt="Docker"/><br/>
      <strong>Docker Build</strong><br/>
      <sub>linux/amd64</sub>
    </td>
    <td align="center">&rarr;<br/><sub>push tag</sub></td>
    <td align="center" width="130">
      <img src="https://cdn.simpleicons.org/docker/2496ED" width="58" alt="DockerHub"/><br/>
      <strong>DockerHub</strong><br/>
      <sub>jmeza17/iac-final-app</sub>
    </td>
  </tr>
  <tr>
    <td colspan="7" align="center"><br/>&darr;<br/><sub>CD: script de despliegue <code>deploy.ps1</code></sub></td>
  </tr>
  <tr>
    <td align="center" width="130">
      <img src="https://cdn.simpleicons.org/terraform/844FBA" width="58" alt="Terraform"/><br/>
      <strong>Terraform</strong><br/>
      <sub>init / apply</sub>
    </td>
    <td align="center">&rarr;<br/><sub>estado remoto</sub></td>
    <td align="center" width="130">
      <img src="https://raw.githubusercontent.com/TaleLearnCode/azure-architecture-icons/main/icons/storage/10086-icon-service-Storage-Accounts.svg" width="58" alt="Azure Storage Account"/><br/>
      <strong>Azure Storage</strong><br/>
      <sub>tfstate</sub>
    </td>
    <td align="center">&rarr;<br/><sub>secreto</sub></td>
    <td align="center" width="130">
      <img src="https://raw.githubusercontent.com/TaleLearnCode/azure-architecture-icons/main/icons/security/10245-icon-service-Key-Vaults.svg" width="58" alt="Azure Key Vault"/><br/>
      <strong>Key Vault</strong><br/>
      <sub>APP_SECRET</sub>
    </td>
    <td align="center">&rarr;<br/><sub>deploy</sub></td>
    <td align="center" width="130">
      <img src="https://raw.githubusercontent.com/TaleLearnCode/azure-architecture-icons/main/icons/other/02989-icon-service-Container-Apps-Environments.svg" width="58" alt="Azure Container Apps"/><br/>
      <strong>Container App</strong><br/>
      <sub>/hello /secreto</sub>
    </td>
  </tr>
</table>

## Diagrama tecnico

```mermaid
flowchart LR
    A["Git push a main<br/>(GitHub: mike1594/iac-final-app)"] --> B["GitHub Actions<br/>(.github/workflows/docker-publish.yml)"]
    B --> C["Docker build<br/>linux/amd64"]
    C --> D["Docker push<br/>jmeza17/iac-final-app:1.0.&lt;run_number&gt;"]
    D --> E["Gatillo: push a main / workflow_dispatch"]
    E --> F["Terraform init<br/>(backend remoto Azure Storage)"]
    F --> G["Terraform apply<br/>(revision Single, nueva imagen)"]
    G --> H["Azure Container App<br/>(ca-joe-meza-iac-app-dev-eus2-001)"]
    H --> I["Verificacion<br/>curl /hello y /secreto"]
```

## Descripcion del flujo

1. **Inicio / gatillo**: un `push` a la rama `main` del repositorio de codigo, o una ejecucion manual (`workflow_dispatch`).
2. **Build**: el workflow de GitHub Actions compila el microservicio Java y construye la imagen Docker para `linux/amd64`.
3. **Push de imagen**: se publica la imagen en DockerHub (`jmeza17/iac-final-app`) con tag automatico `1.0.<run_number>` (ademas de `latest` y el SHA del commit).
4. **IaC / deploy**: con el script `deploy.ps1` se ejecuta `terraform init` contra el backend remoto (Azure Storage privado) y `terraform apply`, que actualiza el Azure Container App a la nueva revision con la imagen publicada.
5. **Verificacion**: se consulta `https://<fqdn>/hello` (devuelve saludo) y `/secreto` (devuelve el secreto desde Key Vault).

## Herramientas

| Herramienta             | Uso                                                 |
| ----------------------- | --------------------------------------------------- |
| GitHub + GitHub Actions | Repositorio y pipeline CI                           |
| Docker + DockerHub      | Containerizacion y registro publico de imagen       |
| Terraform (azurerm)     | Infraestructura como codigo de Azure Container Apps |
| Azure Key Vault         | Secreto expuesto en `/secreto`                      |
| Azure Storage           | Backend remoto del estado de Terraform              |
