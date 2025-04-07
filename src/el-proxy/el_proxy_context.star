def new_el_proxy_client_context(ip_addr, proxy_port_num):
    return struct(
        ip_addr=ip_addr,
        proxy_port_num=proxy_port_num,
    ) 