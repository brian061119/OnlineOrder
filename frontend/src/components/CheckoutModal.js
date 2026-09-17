import { Button, Form, Input, Modal, Radio, Select, message } from "antd";
import { useEffect, useState } from "react";
import { addPaymentMethod, checkout, getPaymentMethods } from "../utils";

const { Option } = Select;

const NEW_CARD = "new";
const CURRENT_YEAR = new Date().getFullYear();
const EXPIRY_YEARS = Array.from({ length: 12 }, (_, i) => CURRENT_YEAR + i);
const EXPIRY_MONTHS = Array.from({ length: 12 }, (_, i) => i + 1);

const CheckoutModal = ({ open, total, onClose, onSuccess }) => {
  const [form] = Form.useForm();
  const [paymentMethods, setPaymentMethods] = useState([]);
  const [loadingMethods, setLoadingMethods] = useState(false);
  const [selectedId, setSelectedId] = useState(NEW_CARD);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!open) {
      return;
    }
    setLoadingMethods(true);
    getPaymentMethods()
      .then((data) => {
        setPaymentMethods(data);
        setSelectedId(data.length > 0 ? data[0].id : NEW_CARD);
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setLoadingMethods(false);
      });
  }, [open]);

  const payWith = (paymentMethodId) => {
    checkout(paymentMethodId)
      .then((order) => {
        message.success(`Order placed! Charged $${order.total_price.toFixed(2)}`);
        form.resetFields();
        onSuccess();
      })
      .catch((err) => {
        message.error(err.message);
      })
      .finally(() => {
        setSubmitting(false);
      });
  };

  const onPay = () => {
    if (selectedId !== NEW_CARD) {
      setSubmitting(true);
      payWith(selectedId);
      return;
    }

    form.validateFields().then((values) => {
      setSubmitting(true);
      addPaymentMethod(values)
        .then((newMethod) => payWith(newMethod.id))
        .catch((err) => {
          message.error(err.message);
          setSubmitting(false);
        });
    });
  };

  return (
    <Modal
      title="Choose a payment method"
      open={open}
      onCancel={onClose}
      destroyOnClose
      confirmLoading={loadingMethods}
      footer={[
        <Button key="cancel" onClick={onClose}>
          Cancel
        </Button>,
        <Button key="pay" type="primary" loading={submitting} onClick={onPay}>
          {`Pay $${(total ?? 0).toFixed(2)}`}
        </Button>,
      ]}
    >
      {paymentMethods.length > 0 && (
        <Radio.Group
          value={selectedId}
          onChange={(e) => setSelectedId(e.target.value)}
          style={{
            display: "flex",
            flexDirection: "column",
            gap: 8,
            marginBottom: 16,
          }}
        >
          {paymentMethods.map((method) => (
            <Radio key={method.id} value={method.id}>
              {`${method.brand} •••• ${method.last_four} (exp ${String(
                method.expiry_month
              ).padStart(2, "0")}/${method.expiry_year})`}
            </Radio>
          ))}
          <Radio value={NEW_CARD}>Use a new card</Radio>
        </Radio.Group>
      )}

      {selectedId === NEW_CARD && (
        <Form form={form} layout="vertical" preserve={false}>
          <Form.Item
            name="card_holder"
            label="Cardholder name"
            rules={[
              { required: true, message: "Please input the cardholder name!" },
            ]}
          >
            <Input placeholder="Jane Doe" />
          </Form.Item>
          <Form.Item
            name="card_number"
            label="Card number"
            rules={[
              { required: true, message: "Please input the card number!" },
              {
                pattern: /^[\d\s-]{12,23}$/,
                message: "Card number looks invalid",
              },
            ]}
          >
            <Input placeholder="4242 4242 4242 4242" maxLength={23} />
          </Form.Item>
          <div style={{ display: "flex", gap: 12 }}>
            <Form.Item
              name="expiry_month"
              label="Month"
              rules={[{ required: true, message: "Required" }]}
              style={{ flex: 1 }}
            >
              <Select placeholder="MM">
                {EXPIRY_MONTHS.map((m) => (
                  <Option key={m} value={m}>
                    {String(m).padStart(2, "0")}
                  </Option>
                ))}
              </Select>
            </Form.Item>
            <Form.Item
              name="expiry_year"
              label="Year"
              rules={[{ required: true, message: "Required" }]}
              style={{ flex: 1 }}
            >
              <Select placeholder="YYYY">
                {EXPIRY_YEARS.map((y) => (
                  <Option key={y} value={y}>
                    {y}
                  </Option>
                ))}
              </Select>
            </Form.Item>
            <Form.Item
              name="cvv"
              label="CVV"
              rules={[
                { required: true, message: "Required" },
                { pattern: /^\d{3,4}$/, message: "3-4 digits" },
              ]}
              style={{ flex: 1 }}
            >
              <Input.Password placeholder="123" maxLength={4} />
            </Form.Item>
          </div>
        </Form>
      )}
    </Modal>
  );
};

export default CheckoutModal;
