import { Avatar, Button, Empty, Input, Spin, Typography, message } from "antd";
import {
  CloseOutlined,
  MessageOutlined,
  RobotOutlined,
  SendOutlined,
  UserOutlined,
} from "@ant-design/icons";
import { useEffect, useRef, useState } from "react";
import { getAiRecommendation } from "../utils";
import AddToCartButton from "./AddToCartButton";

const { Text, Paragraph } = Typography;

const WELCOME_TEXT =
  "你好，我是点餐助手。告诉我你想吃什么（比如“想吃辣的，预算30以内”），我来帮你推荐。";

// 每条消息: { role: "user" | "assistant", text?, recommendations?, disclaimer? }
const AiChatWidget = () => {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const listRef = useRef(null);

  useEffect(() => {
    if (listRef.current) {
      listRef.current.scrollTop = listRef.current.scrollHeight;
    }
  }, [messages, loading, open]);

  const onSend = () => {
    const text = input.trim();
    if (!text || loading) {
      return;
    }

    setMessages((prev) => [...prev, { role: "user", text }]);
    setInput("");
    setLoading(true);

    getAiRecommendation(text)
      .then((data) => {
        setMessages((prev) => [
          ...prev,
          {
            role: "assistant",
            text: data.summary,
            recommendations: data.recommendations,
            disclaimer: data.disclaimer,
          },
        ]);
      })
      .catch((err) => {
        message.error(err.message);
        setMessages((prev) => [
          ...prev,
          { role: "assistant", text: "抱歉，暂时无法生成推荐，请稍后再试。" },
        ]);
      })
      .finally(() => {
        setLoading(false);
      });
  };

  const onKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      onSend();
    }
  };

  return (
    <>
      <Button
        className="ai-chat-fab"
        type="primary"
        shape="circle"
        size="large"
        icon={open ? <CloseOutlined /> : <MessageOutlined />}
        onClick={() => setOpen((v) => !v)}
      />

      {open && (
        <div className="ai-chat-panel">
          <div className="ai-chat-header">
            <RobotOutlined style={{ marginRight: 8 }} />
            <Text strong style={{ color: "#fff" }}>
              AI 点餐助手
            </Text>
          </div>

          <div className="ai-chat-body" ref={listRef}>
            {messages.length === 0 && (
              <div className="ai-chat-bubble ai-chat-bubble-assistant">
                <Avatar
                  size="small"
                  icon={<RobotOutlined />}
                  className="ai-chat-avatar"
                />
                <div className="ai-chat-bubble-content">{WELCOME_TEXT}</div>
              </div>
            )}

            {messages.map((m, idx) => (
              <div
                key={idx}
                className={`ai-chat-bubble ai-chat-bubble-${m.role}`}
              >
                {m.role === "assistant" && (
                  <Avatar
                    size="small"
                    icon={<RobotOutlined />}
                    className="ai-chat-avatar"
                  />
                )}
                <div className="ai-chat-bubble-content">
                  {m.text && <div>{m.text}</div>}

                  {m.recommendations && m.recommendations.length === 0 && (
                    <Empty
                      description="没有找到合适的推荐"
                      image={Empty.PRESENTED_IMAGE_SIMPLE}
                    />
                  )}

                  {m.recommendations?.map((item) => (
                    <div className="ai-chat-item-card" key={item.menu_item_id}>
                      {item.image_url && (
                        <img
                          src={item.image_url}
                          alt={item.name}
                          className="ai-chat-item-image"
                        />
                      )}
                      <div className="ai-chat-item-info">
                        <div className="ai-chat-item-name">{item.name}</div>
                        <div className="ai-chat-item-price">
                          ${item.price}
                        </div>
                        <Paragraph
                          type="secondary"
                          className="ai-chat-item-reason"
                        >
                          {item.reason}
                        </Paragraph>
                      </div>
                      <AddToCartButton itemId={item.menu_item_id} />
                    </div>
                  ))}

                  {m.disclaimer && (
                    <div className="ai-chat-disclaimer">{m.disclaimer}</div>
                  )}
                </div>
                {m.role === "user" && (
                  <Avatar
                    size="small"
                    icon={<UserOutlined />}
                    className="ai-chat-avatar"
                  />
                )}
              </div>
            ))}

            {loading && (
              <div className="ai-chat-bubble ai-chat-bubble-assistant">
                <Avatar
                  size="small"
                  icon={<RobotOutlined />}
                  className="ai-chat-avatar"
                />
                <div className="ai-chat-bubble-content">
                  <Spin size="small" /> 正在生成推荐...
                </div>
              </div>
            )}
          </div>

          <div className="ai-chat-footer">
            <Input
              placeholder="想吃什么？说说你的需求..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={onKeyDown}
              disabled={loading}
            />
            <Button
              type="primary"
              icon={<SendOutlined />}
              onClick={onSend}
              loading={loading}
              disabled={!input.trim()}
            />
          </div>
        </div>
      )}
    </>
  );
};

export default AiChatWidget;
