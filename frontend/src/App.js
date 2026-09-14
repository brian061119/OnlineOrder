import { Layout, Tabs, Typography } from "antd";
import { useState } from "react";
import AdminPanel from "./components/AdminPanel";
import FoodList from "./components/FoodList";
import LoginForm from "./components/LoginForm";
import MyCart from "./components/MyCart";
import SignupForm from "./components/SignupForm";
import { getCurrentUser } from "./utils";

const { Header, Content } = Layout;
const { Title } = Typography;
const { TabPane } = Tabs;

function App() {
  const [authed, setAuthed] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);

  const onLoginSuccess = () => {
    setAuthed(true);
    getCurrentUser()
      .then((user) => setIsAdmin(user.is_admin))
      .catch(() => setIsAdmin(false));
  };

  return (
    <Layout style={{ height: "100vh" }}>
      <Header>
        <div
          className="header"
          style={{ display: "flex", justifyContent: "space-between" }}
        >
          <Title
            level={2}
            style={{ color: "white", lineHeight: "inherit", marginBottom: 0 }}
          >
            MyFood
          </Title>
          <div>{authed ? <MyCart /> : <SignupForm />}</div>
        </div>
      </Header>
      <Content
        style={{
          padding: "50px",
          maxHeight: "calc(100% - 64px)",
          overflowY: "auto",
        }}
      >
        {authed ? (
          isAdmin ? (
            <Tabs defaultActiveKey="order">
              <TabPane tab="Order" key="order">
                <FoodList />
              </TabPane>
              <TabPane tab="Admin" key="admin">
                <AdminPanel />
              </TabPane>
            </Tabs>
          ) : (
            <FoodList />
          )
        ) : (
          <LoginForm onSuccess={onLoginSuccess} />
        )}
      </Content>
    </Layout>
  );
}

export default App;
