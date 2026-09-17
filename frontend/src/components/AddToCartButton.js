import { Button, Dropdown, InputNumber, Menu, Modal, message } from "antd";
import { useState } from "react";
import { PlusOutlined } from "@ant-design/icons";
import { addItemToCart } from "../utils";

const QUANTITY_OPTIONS = [1, 2, 3, 4, 5, 6];
const MAX_CUSTOM_QUANTITY = 10;

const AddToCartButton = ({ itemId }) => {
  const [loading, setLoading] = useState(false);
  const [customModalOpen, setCustomModalOpen] = useState(false);
  const [customQuantity, setCustomQuantity] = useState(null);

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

  const onMenuClick = ({ key }) => {
    if (key === "custom") {
      setCustomQuantity(null);
      setCustomModalOpen(true);
      return;
    }
    onSelectQuantity(Number(key));
  };

  const onCustomConfirm = () => {
    if (!customQuantity || customQuantity < 1) {
      message.error("Please enter a valid quantity");
      return;
    }
    if (customQuantity > MAX_CUSTOM_QUANTITY) {
      message.error(`You can only order up to ${MAX_CUSTOM_QUANTITY} at a time`);
      return;
    }
    setCustomModalOpen(false);
    onSelectQuantity(customQuantity);
  };

  const quantityMenu = (
    <Menu className="quantity-menu" onClick={onMenuClick}>
      {QUANTITY_OPTIONS.map((quantity) => (
        <Menu.Item key={quantity}>{quantity}</Menu.Item>
      ))}
      <Menu.Divider />
      <Menu.Item key="custom">Custom…</Menu.Item>
    </Menu>
  );

  return (
    <>
      <Dropdown overlay={quantityMenu} trigger={["click"]} placement="topRight">
        <Button
          className="add-to-cart-btn"
          loading={loading}
          type="primary"
          shape="circle"
          icon={<PlusOutlined />}
        />
      </Dropdown>
      <Modal
        title="Custom quantity"
        open={customModalOpen}
        onOk={onCustomConfirm}
        onCancel={() => setCustomModalOpen(false)}
        okText="Add to cart"
        destroyOnClose
      >
        <InputNumber
          min={1}
          value={customQuantity}
          onChange={setCustomQuantity}
          onPressEnter={onCustomConfirm}
          style={{ width: "100%" }}
          placeholder={`How many? (max ${MAX_CUSTOM_QUANTITY})`}
          autoFocus
        />
      </Modal>
    </>
  );
};

export default AddToCartButton;
