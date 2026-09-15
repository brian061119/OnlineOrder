import { Button, Dropdown, Menu, message } from "antd";
import { useState } from "react";
import { PlusOutlined } from "@ant-design/icons";
import { addItemToCart } from "../utils";

const QUANTITY_OPTIONS = [1, 2, 3, 4, 5, 6];

const AddToCartButton = ({ itemId }) => {
  const [loading, setLoading] = useState(false);

  const onSelectQuantity = (quantity) => {
    setLoading(true);
    addItemToCart(itemId, quantity)
      .then(() => {
        message.success(`Added ${quantity} to cart`);
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setLoading(false);
      });
  };

  const quantityMenu = (
    <Menu
      className="quantity-menu"
      onClick={({ key }) => onSelectQuantity(Number(key))}
    >
      {QUANTITY_OPTIONS.map((quantity) => (
        <Menu.Item key={quantity}>{quantity}</Menu.Item>
      ))}
    </Menu>
  );

  return (
    <Dropdown overlay={quantityMenu} trigger={["click"]} placement="topRight">
      <Button
        className="add-to-cart-btn"
        loading={loading}
        type="primary"
        shape="circle"
        icon={<PlusOutlined />}
      />
    </Dropdown>
  );
};

export default AddToCartButton;
