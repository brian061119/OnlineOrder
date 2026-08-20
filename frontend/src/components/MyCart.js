import { Button, Drawer, List, message, Typography } from "antd";
import { DeleteOutlined, MinusOutlined, PlusOutlined } from "@ant-design/icons";
import { useEffect, useState } from "react";
import { checkout, getCart, removeCartItem, updateCartItem } from "../utils";

const { Text } = Typography;

const MyCart = () => {
  const [cartVisible, setCartVisible] = useState(false);
  const [cartData, setCartData] = useState();
  const [loading, setLoading] = useState(false);
  const [checking, setChecking] = useState(false);
  // 正在请求中的那一条的 id，用来只禁用那一行的按钮，而不是整个抽屉
  const [busyItemId, setBusyItemId] = useState(null);

  // get ths shopping cart data
  useEffect(() => {
    if (!cartVisible) {
      return;
    }

    setLoading(true);
    getCart()
      .then((data) => {
        setCartData(data);
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setLoading(false);
      });
  }, [cartVisible]);

  // 后端返回的是更新后的整个 cart，直接拿来覆盖本地状态即可
  const onQuantityChange = (orderItemId, quantity) => {
    setBusyItemId(orderItemId);
    updateCartItem(orderItemId, quantity)
      .then((data) => {
        setCartData(data);
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setBusyItemId(null);
      });
  };

  const onRemove = (orderItemId) => {
    setBusyItemId(orderItemId);
    removeCartItem(orderItemId)
      .then((data) => {
        setCartData(data);
        message.success("Item removed");
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setBusyItemId(null);
      });
  };

  const onCheckOut = () => {
    setChecking(true);
    checkout()
      .then(() => {
        message.success("Successfully checkout");
        setCartVisible(false);
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setChecking(false);
      });
  };

  const onCloseDrawer = () => {
    setCartVisible(false);
  };

  const onOpenDrawer = () => {
    setCartVisible(true);
  };

  return (
    <>
      <Button type="primary" shape="round" onClick={onOpenDrawer}>
        Cart
      </Button>
      <Drawer
        title="My Shopping Cart"
        onClose={onCloseDrawer}
        open={cartVisible}
        width={520}
        footer={
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
            }}
          >
            <Text
              strong={true}
            >{`Total price: $${cartData?.total_price}`}</Text>
            <div>
              <Button onClick={onCloseDrawer} style={{ marginRight: 8 }}>
                Cancel
              </Button>
              <Button
                onClick={onCheckOut}
                type="primary"
                loading={checking}
                disabled={loading || cartData?.order_items.length === 0}
              >
                Checkout
              </Button>
            </div>
          </div>
        }
      >
        <List
          loading={loading}
          itemLayout="horizontal"
          dataSource={cartData?.order_items}
          renderItem={(item) => {
            const busy = busyItemId === item.order_item_id;
            return (
              <List.Item
                actions={[
                  // 数量减到 0 时后端会直接删除该条目，所以这里不用特判
                  <Button
                    key="minus"
                    size="small"
                    icon={<MinusOutlined />}
                    disabled={busy}
                    onClick={() =>
                      onQuantityChange(item.order_item_id, item.quantity - 1)
                    }
                  />,
                  <Text key="qty" strong={true}>
                    {item.quantity}
                  </Text>,
                  <Button
                    key="plus"
                    size="small"
                    icon={<PlusOutlined />}
                    disabled={busy}
                    onClick={() =>
                      onQuantityChange(item.order_item_id, item.quantity + 1)
                    }
                  />,
                  <Button
                    key="remove"
                    size="small"
                    type="text"
                    danger
                    icon={<DeleteOutlined />}
                    loading={busy}
                    onClick={() => onRemove(item.order_item_id)}
                  />,
                ]}
              >
                <List.Item.Meta
                  title={item.menu_item_name}
                  description={`$${item.price} each`}
                />
              </List.Item>
            );
          }}
        />
      </Drawer>
    </>
  );
};

export default MyCart;
