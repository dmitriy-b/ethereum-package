shared_utils = import_module("../shared_utils/shared_utils.star")
constants = import_module("../package_io/constants.star")
input_parser = import_module("../package_io/input_parser.star")
el_context = import_module("../el/el_context.star")
el_proxy_context = import_module("../el-proxy/el_proxy_context.star")

EL_PROXY_PORT_NUM = 9551
EL_PROXY_PORT_ID = "http"
EL_PROXY_BINARY_COMMAND = "EngineApiProxy"

EL_PROXY_USED_PORTS = {
    EL_PROXY_PORT_ID: shared_utils.new_port_spec(
        EL_PROXY_PORT_NUM, shared_utils.TCP_PROTOCOL, wait="5s"
    ),
}

# The min/max CPU/memory that el-proxy can use
MIN_CPU = 50
MAX_CPU = 200
MIN_MEMORY = 128
MAX_MEMORY = 600

# Define default Docker image for the Engine API Proxy
DEFAULT_EL_PROXY_IMAGE = "nethermindeth/engine-api-proxy:latest"

def launch(plan, service_name, el_context, node_selectors, docker_cache_params):
    el_proxy_service_name = "{0}".format(service_name)

    el_proxy_config = get_config(
        service_name,
        el_context,
        node_selectors,
        docker_cache_params,
    )

    el_proxy_service = plan.add_service(el_proxy_service_name, el_proxy_config)
    el_proxy_http_port = el_proxy_service.ports[EL_PROXY_PORT_ID]
    return el_proxy_context.new_el_proxy_client_context(
        el_proxy_service.ip_address, EL_PROXY_PORT_NUM
    )


def get_config(service_name, el_context, node_selectors, docker_cache_params):
    # Format the execution client endpoint
    ec_endpoint = "http://{0}:{1}".format(
        el_context.ip_addr,
        el_context.engine_rpc_port_num,
    )
    
    # Update command format based on error message requirements
    cmd = [
        EL_PROXY_BINARY_COMMAND,
        "--ec-endpoint={0}".format(ec_endpoint),
        "--port={0}".format(EL_PROXY_PORT_NUM),
        "--validate-all-blocks",
        "--log-level=Debug"  # Log level
    ]

    # Use either a custom image from cache or default image
    image = shared_utils.docker_cache_image_calc(
        docker_cache_params, DEFAULT_EL_PROXY_IMAGE
    )
    
    return ServiceConfig(
        image=image,
        ports=EL_PROXY_USED_PORTS,
        cmd=cmd,
        min_cpu=MIN_CPU,
        max_cpu=MAX_CPU,
        min_memory=MIN_MEMORY,
        max_memory=MAX_MEMORY,
        node_selectors=node_selectors,
    ) 