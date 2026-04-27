import asyncio
import logging
from pathlib import Path
from typing import AsyncIterator, Optional

import nest_asyncio
from cliver import AgentCore
from cliver.config import ConfigManager
from cliver.util import get_config_dir

logger = logging.getLogger(__name__)

# Allow asyncio.run() inside Jupyter's already-running event loop
nest_asyncio.apply()


class PlaygroundAgent:
    """Thin wrapper around CLIver's AgentCore for notebook experiments."""

    def __init__(
        self,
        config_dir: Optional[Path] = None,
        default_model: Optional[str] = None,
        agent_name: str = "Playground",
    ):
        self._config_manager = ConfigManager(config_dir or get_config_dir())
        llm_models = self._config_manager.list_llm_models()
        mcp_servers = self._config_manager.list_mcp_servers_for_mcp_caller()

        if default_model is None:
            dm = self._config_manager.get_llm_model()
            default_model = dm.name if dm else None

        self.core = AgentCore(
            llm_models=llm_models,
            mcp_servers=mcp_servers,
            default_model=default_model,
            agent_name=agent_name,
        )
        self.core.configure_rate_limits(self._config_manager.config.providers)

    def list_models(self) -> list[str]:
        return list(self._config_manager.list_llm_models().keys())

    def chat(
        self,
        prompt: str,
        *,
        model: Optional[str] = None,
        system_message: Optional[str] = None,
        images: Optional[list[str]] = None,
    ) -> str:
        """Synchronous chat — works in both scripts and Jupyter notebooks."""
        response = self.core.process_user_input_sync(
            prompt,
            model=model,
            system_message_appender=lambda: system_message if system_message else None,
            images=images,
        )
        return response.content

    async def chat_async(
        self,
        prompt: str,
        *,
        model: Optional[str] = None,
        system_message: Optional[str] = None,
        images: Optional[list[str]] = None,
    ) -> str:
        """Async chat — returns the response text."""
        response = await self.core.process_user_input(
            prompt,
            model=model,
            system_message_appender=lambda: system_message if system_message else None,
            images=images,
        )
        return response.content

    async def stream(
        self,
        prompt: str,
        *,
        model: Optional[str] = None,
        system_message: Optional[str] = None,
    ) -> AsyncIterator[str]:
        """Async streaming — yields text chunks."""
        async for chunk in self.core.stream_user_input(
            prompt,
            model=model,
            system_message_appender=lambda: system_message if system_message else None,
        ):
            if chunk.content:
                yield chunk.content


def get_agent(
    default_model: Optional[str] = None,
    config_dir: Optional[Path] = None,
) -> PlaygroundAgent:
    """Convenience factory for creating a PlaygroundAgent."""
    return PlaygroundAgent(config_dir=config_dir, default_model=default_model)
