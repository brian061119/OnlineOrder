import {
  Button,
  Form,
  Input,
  InputNumber,
  message,
  Modal,
  Popconfirm,
  Space,
  Table,
} from "antd";
import { useEffect, useState } from "react";
import {
  createMenuItem,
  createRestaurant,
  deleteMenuItem,
  deleteRestaurant,
  getRestaurants,
  updateMenuItem,
  updateRestaurant,
} from "../utils";

const RestaurantForm = ({ initialValues, onCancel, onSubmit }) => {
  const [form] = Form.useForm();

  return (
    <Modal
      title={initialValues ? "Edit Restaurant" : "Add Restaurant"}
      open={true}
      onCancel={onCancel}
      onOk={() => form.validateFields().then(onSubmit)}
      destroyOnClose
    >
      <Form
        form={form}
        layout="vertical"
        initialValues={initialValues}
        preserve={false}
      >
        <Form.Item
          name="name"
          label="Name"
          rules={[{ required: true, message: "Please input the name!" }]}
        >
          <Input />
        </Form.Item>
        <Form.Item name="address" label="Address">
          <Input />
        </Form.Item>
        <Form.Item name="phone" label="Phone">
          <Input />
        </Form.Item>
        <Form.Item name="image_url" label="Image URL">
          <Input />
        </Form.Item>
      </Form>
    </Modal>
  );
};

const MenuItemForm = ({ initialValues, onCancel, onSubmit }) => {
  const [form] = Form.useForm();

  return (
    <Modal
      title={initialValues ? "Edit Menu Item" : "Add Menu Item"}
      open={true}
      onCancel={onCancel}
      onOk={() => form.validateFields().then(onSubmit)}
      destroyOnClose
    >
      <Form
        form={form}
        layout="vertical"
        initialValues={initialValues}
        preserve={false}
      >
        <Form.Item
          name="name"
          label="Name"
          rules={[{ required: true, message: "Please input the name!" }]}
        >
          <Input />
        </Form.Item>
        <Form.Item name="description" label="Description">
          <Input />
        </Form.Item>
        <Form.Item
          name="price"
          label="Price"
          rules={[{ required: true, message: "Please input the price!" }]}
        >
          <InputNumber min={0} step={0.01} style={{ width: "100%" }} />
        </Form.Item>
        <Form.Item name="image_url" label="Image URL">
          <Input />
        </Form.Item>
      </Form>
    </Modal>
  );
};

const AdminPanel = () => {
  const [restaurants, setRestaurants] = useState([]);
  const [loading, setLoading] = useState(false);
  // null, or { restaurant: null | restaurant } while the add/edit modal is open
  const [restaurantModal, setRestaurantModal] = useState(null);
  // null, or { restaurantId, menuItem: null | menuItem } while the add/edit modal is open
  const [menuItemModal, setMenuItemModal] = useState(null);

  const loadRestaurants = () => {
    setLoading(true);
    return getRestaurants()
      .then((data) => setRestaurants(data))
      .catch((err) => message.error(err.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadRestaurants();
  }, []);

  const onRestaurantSubmit = (values) => {
    const request = restaurantModal.restaurant
      ? updateRestaurant(restaurantModal.restaurant.id, values)
      : createRestaurant(values);
    request
      .then(() => {
        message.success("Saved");
        setRestaurantModal(null);
        loadRestaurants();
      })
      .catch((err) => message.error(err.message));
  };

  const onRestaurantDelete = (restaurantId) => {
    deleteRestaurant(restaurantId)
      .then(() => {
        message.success("Deleted");
        loadRestaurants();
      })
      .catch((err) => message.error(err.message));
  };

  const onMenuItemSubmit = (values) => {
    const { restaurantId, menuItem } = menuItemModal;
    const request = menuItem
      ? updateMenuItem(menuItem.id, values)
      : createMenuItem(restaurantId, values);
    request
      .then(() => {
        message.success("Saved");
        setMenuItemModal(null);
        loadRestaurants();
      })
      .catch((err) => message.error(err.message));
  };

  const onMenuItemDelete = (menuItemId) => {
    deleteMenuItem(menuItemId)
      .then(() => {
        message.success("Deleted");
        loadRestaurants();
      })
      .catch((err) => message.error(err.message));
  };

  const restaurantColumns = [
    { title: "Name", dataIndex: "name" },
    { title: "Address", dataIndex: "address" },
    { title: "Phone", dataIndex: "phone" },
    {
      title: "Actions",
      render: (_, restaurant) => (
        <Space>
          <Button
            size="small"
            onClick={() => setRestaurantModal({ restaurant })}
          >
            Edit
          </Button>
          <Popconfirm
            title="Delete this restaurant?"
            onConfirm={() => onRestaurantDelete(restaurant.id)}
          >
            <Button size="small" danger>
              Delete
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const menuItemColumns = (restaurantId) => [
    { title: "Name", dataIndex: "name" },
    { title: "Description", dataIndex: "description" },
    { title: "Price", dataIndex: "price" },
    {
      title: "Actions",
      render: (_, menuItem) => (
        <Space>
          <Button
            size="small"
            onClick={() => setMenuItemModal({ restaurantId, menuItem })}
          >
            Edit
          </Button>
          <Popconfirm
            title="Delete this item?"
            onConfirm={() => onMenuItemDelete(menuItem.id)}
          >
            <Button size="small" danger>
              Delete
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <>
      <Button
        type="primary"
        onClick={() => setRestaurantModal({ restaurant: null })}
      >
        Add Restaurant
      </Button>
      <Table
        style={{ marginTop: 16 }}
        rowKey="id"
        loading={loading}
        dataSource={restaurants}
        columns={restaurantColumns}
        expandable={{
          expandedRowRender: (restaurant) => (
            <>
              <Button
                size="small"
                style={{ marginBottom: 8 }}
                onClick={() =>
                  setMenuItemModal({ restaurantId: restaurant.id, menuItem: null })
                }
              >
                Add Menu Item
              </Button>
              <Table
                rowKey="id"
                dataSource={restaurant.menu_items}
                columns={menuItemColumns(restaurant.id)}
                pagination={false}
              />
            </>
          ),
        }}
      />
      {restaurantModal && (
        <RestaurantForm
          initialValues={restaurantModal.restaurant}
          onCancel={() => setRestaurantModal(null)}
          onSubmit={onRestaurantSubmit}
        />
      )}
      {menuItemModal && (
        <MenuItemForm
          initialValues={menuItemModal.menuItem}
          onCancel={() => setMenuItemModal(null)}
          onSubmit={onMenuItemSubmit}
        />
      )}
    </>
  );
};

export default AdminPanel;
