import contextlib
import time
import warnings
import requests
from urllib3.exceptions import InsecureRequestWarning

from src.typings import *
from src.utils import *
from ..agent import AgentClient


old_merge_environment_settings = requests.Session.merge_environment_settings

@contextlib.contextmanager
def no_ssl_verification():
    opened_adapters = set()

    def merge_environment_settings(self, url, proxies, stream, verify, cert):
        opened_adapters.add(self.get_adapter(url))
        settings = old_merge_environment_settings(self, url, proxies, stream, verify, cert)
        settings['verify'] = False
        return settings

    requests.Session.merge_environment_settings = merge_environment_settings
    try:
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', InsecureRequestWarning)
            yield
    finally:
        requests.Session.merge_environment_settings = old_merge_environment_settings
        for adapter in opened_adapters:
            try:
                adapter.close()
            except:
                pass


class Prompter:
    @staticmethod
    def get_prompter(prompter: Union[Dict[str, Any], None]):
        if not prompter:
            return Prompter.default()
        assert isinstance(prompter, dict)
        prompter_name = prompter.get("name", None)
        prompter_args = prompter.get("args", {})
        if hasattr(Prompter, prompter_name) and callable(getattr(Prompter, prompter_name)):
            return getattr(Prompter, prompter_name)(**prompter_args)
        return Prompter.default()

    @staticmethod
    def default():
        return Prompter.openai_chat()

    @staticmethod
    def openai_chat():
        def prompter(messages: List[Dict[str, str]]):
            return {"messages": [{"role": m["role"], "content": m["content"]} for m in messages]}
        return prompter


def check_context_limit(content: str):
    content = content.lower()
    and_words = [
        ["prompt", "context", "tokens"],
        ["limit", "exceed", "max", "long", "much", "many", "reach", "over", "up", "beyond"],
    ]
    rule = AndRule([
        OrRule([ContainRule(word) for word in group]) for group in and_words
    ])
    return rule.check(content)


class VLLMAgent(AgentClient):
    def __init__(
        self,
        url,
        # model="Qwen/Qwen2.5-7B-Instruct",
        # model = "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
        model,
        temperature=0,
        top_p=0.95,
        max_tokens=1024,
        headers=None,
        return_format="{response['choices'][0]['message']['content']}",
        prompter=None,
        proxies=None,
        **kwargs,
    ):
        super().__init__(**kwargs)
        if url.startswith("https://localhost") or url.startswith("https://127.0.0.1"):
            raise ValueError("Use HTTP, not HTTPS, for local vLLM server.")

        self.url = url.rstrip("/")
        self.model = model
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.top_p = top_p
        self.headers = headers or {"Content-Type": "application/json"}
        self.return_format = return_format
        self.prompter = Prompter.get_prompter(prompter)
        self.proxies = proxies or {}

    def _handle_history(self, history: List[dict]) -> Dict[str, Any]:
        return self.prompter(history)

    def inference(self, history: List[dict]) -> str:
        for attempt in range(3):
            try:
                body = {
                    "model": self.model,
                    "temperature": self.temperature,
                    "max_tokens": self.max_tokens,
                    "top_p": self.top_p,
                }
                body.update(self._handle_history(history))

                with no_ssl_verification():
                    resp = requests.post(
                        self.url, json=body, headers=self.headers,
                        proxies=self.proxies, timeout=120
                    )

                if resp.status_code != 200:
                    if check_context_limit(resp.text):
                        raise AgentContextLimitException(resp.text)
                    raise Exception(f"Status {resp.status_code}: {resp.text}")

                response = resp.json()
                return self.return_format.format(response=response)

            except AgentClientException as e:
                raise e
            except Exception as e:
                print("Warning:", e)
                time.sleep(attempt + 2)
        raise Exception("Inference failed after 3 attempts.")
