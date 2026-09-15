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
              <Input prefix={<UserOutlined />} placeholder="Username" />
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
