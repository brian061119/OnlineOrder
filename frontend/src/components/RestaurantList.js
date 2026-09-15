import { Card, List, message } from "antd";
import { useEffect, useState } from "react";
import { getRestaurants } from "../utils";

const RestaurantList = ({ onSelect }) => {
  const [restaurants, setRestaurants] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    getRestaurants()
      .then((data) => {
        setRestaurants(data);
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  return (
    <div className="restaurant-page">
      <div className="restaurant-page-title">Choose a restaurant</div>
      <List
        className="restaurant-list"
        loading={{ spinning: loading, tip: "Finding restaurants near you..." }}
        grid={{ gutter: 16, xs: 1, sm: 2, md: 3, lg: 4, xl: 4, xxl: 4 }}
        dataSource={restaurants}
        renderItem={(restaurant) => (
          <List.Item>
            <Card
              className="restaurant-card"
              bordered={false}
              hoverable
              onClick={() => onSelect(restaurant)}
              cover={
                <div className="restaurant-card-media">
                  <img
                    src={restaurant.image_url}
                    alt={restaurant.name}
                    className="restaurant-card-img"
                  />
                </div>
              }
            >
              <div className="restaurant-name">{restaurant.name}</div>
              {restaurant.address && (
                <div className="restaurant-address">{restaurant.address}</div>
              )}
            </Card>
          </List.Item>
        )}
      />
    </div>
  );
};

export default RestaurantList;
