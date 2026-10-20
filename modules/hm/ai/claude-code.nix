{
  programs.claude-code = {
    enable = true;
    mcpServers.linear = {
      type = "http";
      url = "https://mcp.linear.app/mcp";
    };
  };
}
