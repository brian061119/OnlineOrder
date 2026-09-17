import {Button, Form, Input, message, Typography} from "antd";
import React from "react";
import { LockOutlined, UserOutlined } from "@ant-design/icons";
import { login } from "../utils";

const { Title } = Typography;

class LoginForm extends React.Component {
  state = {
    loading: false,
  };

  onFinish = (data) => {
    this.setState({
      loading: true,
    });
    login(data)
      .then(() => {
        message.success(`Login Successful`);
        this.props.onSuccess();
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        this.setState({
          loading: false,
        });
      });
 };

  render() {
    return (
      <div className="login-page">
        <div className="login-page-deco" aria-hidden="true">
          <svg
            className="deco-burger"
            viewBox="0 0 220 190"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M25 95C25 55 60 22 110 22C160 22 195 55 195 95H25Z"
              fill="currentColor"
            />
            <circle cx="80" cy="55" r="5" fill="var(--moo-cream)" />
            <circle cx="110" cy="42" r="5" fill="var(--moo-cream)" />
            <circle cx="140" cy="55" r="5" fill="var(--moo-cream)" />
            <circle cx="95" cy="65" r="4" fill="var(--moo-cream)" />
            <circle cx="128" cy="66" r="4" fill="var(--moo-cream)" />
            <path
              d="M15 103C15 99 18 96 22 96H198C202 96 205 99 205 103C205 108 197 118 182 118C170 130 150 136 133 121C114 138 98 138 82 121C64 136 44 130 33 118C21 118 15 111 15 103Z"
              fill="currentColor"
              opacity="0.75"
            />
            <rect
              x="20"
              y="122"
              width="180"
              height="26"
              rx="12"
              fill="currentColor"
              opacity="0.6"
            />
            <path
              d="M18 152C18 148 21 145 25 145H195C199 145 202 148 202 152C202 168 178 180 110 180C42 180 18 168 18 152Z"
              fill="currentColor"
            />
          </svg>
          <svg
            className="deco-fries"
            viewBox="0 0 140 190"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect
              x="14"
              y="46"
              width="10"
              height="80"
              rx="4"
              transform="rotate(-8 14 46)"
              fill="currentColor"
            />
            <rect
              x="34"
              y="26"
              width="10"
              height="98"
              rx="4"
              transform="rotate(-3 34 26)"
              fill="currentColor"
            />
            <rect x="54" y="18" width="10" height="106" rx="4" fill="currentColor" />
            <rect
              x="74"
              y="24"
              width="10"
              height="100"
              rx="4"
              transform="rotate(4 74 24)"
              fill="currentColor"
            />
            <rect
              x="94"
              y="42"
              width="10"
              height="82"
              rx="4"
              transform="rotate(9 94 42)"
              fill="currentColor"
            />
            <path
              d="M20 118H120L106 182C105 186 101 189 97 189H43C39 189 35 186 34 182L20 118Z"
              fill="currentColor"
              opacity="0.85"
            />
            <path
              d="M20 118H120L116 138H24L20 118Z"
              fill="var(--moo-cream)"
              opacity="0.5"
            />
          </svg>
        </div>
        <div className="login-card">
          <div className="login-brand">
            <span className="login-icon" aria-hidden="true">
              <svg width="52" height="52" viewBox="0 0 56 56" fill="none">
                <path
                  className="steam steam-1"
                  d="M20 15c-1.8 2.6 1.8 4.4 0 7"
                  stroke="currentColor"
                  strokeWidth="2.5"
                  strokeLinecap="round"
                />
                <path
                  className="steam steam-2"
                  d="M28 12c-1.8 2.6 1.8 4.4 0 7"
                  stroke="currentColor"
                  strokeWidth="2.5"
                  strokeLinecap="round"
                />
                <path
                  className="steam steam-3"
                  d="M36 15c-1.8 2.6 1.8 4.4 0 7"
                  stroke="currentColor"
                  strokeWidth="2.5"
                  strokeLinecap="round"
                />
                <path
                  d="M10 26h36a1 1 0 011 1c0 10.5-8.5 19-19 19S9 37.5 9 27a1 1 0 011-1z"
                  fill="currentColor"
                  opacity="0.15"
                />
                <path
                  d="M10 26h36a1 1 0 011 1c0 10.5-8.5 19-19 19S9 37.5 9 27a1 1 0 011-1z"
                  stroke="currentColor"
                  strokeWidth="2.5"
                />
              </svg>
            </span>
            <Title level={3} className="login-title">
              Welcome back
            </Title>
          </div>
          <div className="login-subtitle">
            Sign in to order something delicious
          </div>
          <Form name="normal_login" onFinish={this.onFinish}>
            <Form.Item
              name="username"
              rules={[
                { required: true, message: "Please input your Username!" },
              ]}
            >
              <Input
                prefix={<UserOutlined />}
                placeholder="Username"
                autoComplete="username"
              />
            </Form.Item>
            <Form.Item
              name="password"
              rules={[
                { required: true, message: "Please input your Password!" },
              ]}
            >
              <Input.Password
                prefix={<LockOutlined />}
                placeholder="Password"
                autoComplete="current-password"
              />
            </Form.Item>

            <Form.Item style={{ marginBottom: 0 }}>
              <Button
                type="primary"
                htmlType="submit"
                loading={this.state.loading}
              >
                Login
              </Button>
            </Form.Item>
          </Form>
        </div>
      </div>
    );
  };
}

export default LoginForm;
