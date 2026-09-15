import { useState } from "react";
import RestaurantList from "./RestaurantList";
import MenuList from "./MenuList";

const FoodList = () => {
  const [selectedRestaurant, setSelectedRestaurant] = useState(null);

  return selectedRestaurant ? (
    <MenuList
      restaurant={selectedRestaurant}
      onBack={() => setSelectedRestaurant(null)}
    />
  ) : (
    <RestaurantList onSelect={setSelectedRestaurant} />
  );
};

export default FoodList;
