import type { App } from 'vue';

import {
  Button,
  Card,
  Col,
  Divider,
  Dropdown,
  Form,
  Input,
  InputNumber,
  Layout,
  List,
  Menu,
  Popconfirm,
  Popover,
  Progress,
  Row,
  Select,
  Space,
  Statistic,
  Switch,
  Table,
  Tabs,
  Tag,
  Tree,
  Upload,
} from 'ant-design-vue';

/**
 * 注册全局组件
 * @param app
 */
export function registerGlobComp(app: App) {
  app
    .use(Input)
    .use(Button)
    .use(Layout)
    .use(List)
    .use(Upload)
    .use(Space)
    .use(Card)
    .use(Form)
    .use(Switch)
    .use(Select)
    .use(Popconfirm)
    .use(Popover)
    .use(InputNumber)
    .use(Progress)
    .use(Dropdown)
    .use(Statistic)
    .use(Tag)
    .use(Tabs)
    .use(Divider)
    .use(Menu)
    .use(Table)
    .use(Col)
    .use(Row)
    .use(Tree);
}
