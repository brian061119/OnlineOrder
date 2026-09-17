import { Button, Card, List, message } from "antd";
import { useEffect, useState } from "react";
import { ArrowLeftOutlined } from "@ant-design/icons";
import { getMenus } from "../utils";
import AddToCartButton from "./AddToCartButton";

const MenuList = ({ restaurant, onBack }) => {
  const [foodData, setFoodData] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    getMenus(restaurant.id)
      .then((data) => {
        setFoodData(data);
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [restaurant.id]);

  return (
    <div className="menu-page">
      <div className="menu-page-header">
        <Button
          className="back-btn"
          icon={<ArrowLeftOutlined />}
          onClick={onBack}
        >
          Back to restaurants
        </Button>
        <span className="menu-page-title">{restaurant.name}</span>
      </div>
      <List
        className="dish-list"
        loading={{ spinning: loading, tip: "Fetching today's menu..." }}
        grid={{
          gutter: 16,
          xs: 1,
          sm: 2,
          md: 4,
          lg: 4,
          xl: 3,
          xxl: 3,
        }}
        dataSource={foodData}
        renderItem={(item) => (
          <List.Item>
            <Card
              className="dish-card"
              bordered={false}
              cover={
                <div className="dish-card-media">
                  <img
                    src={item.image_url}
                    alt={item.name}
                    className="dish-card-img"
                  />
                  <div className="dish-card-media-fab">
                    <AddToCartButton itemId={item.id} />
                  </div>
                </div>
              }
            >
              <div className="dish-card-header">
                <span className="dish-name">{item.name}</span>
                <span className="dish-price">
                  ${Number(item.price).toFixed(2)}
                </span>
              </div>
              {item.description && (
                <p className="dish-desc">{item.description}</p>
              )}
            </Card>
          </List.Item>
        )}
      />
    </div>
  );
};

export default MenuList;
