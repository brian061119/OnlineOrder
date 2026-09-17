import { Card, Input, List, message } from "antd";
import { SearchOutlined } from "@ant-design/icons";
import { useEffect, useMemo, useState } from "react";
import { getRestaurants } from "../utils";

const RestaurantList = ({ onSelect }) => {
  const [restaurants, setRestaurants] = useState([]);
  const [loading, setLoading] = useState(false);
  const [query, setQuery] = useState("");

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

  const filteredRestaurants = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    if (!normalized) {
      return restaurants;
    }
    return restaurants.filter((restaurant) =>
      restaurant.name.toLowerCase().includes(normalized)
    );
  }, [restaurants, query]);

  return (
    <div className="restaurant-page">
      <div className="restaurant-page-title">Choose a restaurant</div>
      <Input
        className="restaurant-search"
        size="large"
        prefix={<SearchOutlined />}
        placeholder="Search restaurants..."
        allowClear
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      <List
        className="restaurant-list"
        loading={{ spinning: loading, tip: "Finding restaurants near you..." }}
        grid={{ gutter: 16, xs: 1, sm: 2, md: 3, lg: 4, xl: 4, xxl: 4 }}
        dataSource={filteredRestaurants}
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
