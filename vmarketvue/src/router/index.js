import { createRouter, createWebHistory } from 'vue-router'
import store from '@/store'
import HomeView from '../views/HomeView.vue'

import Product from '../views/Product.vue'
import Category from '../views/Category.vue'
import Search from '../views/Search.vue'
import Cart from '../views/Cart.vue'
import SignUp from '../views/SignUp.vue'
import LogIn from '../views/LogIn.vue'
import MyAccount from '../views/MyAccount.vue'
import Profile from '../views/Profile.vue'
import Orders from '../views/Orders.vue'
import OrderDetail from '../views/OrderDetail.vue'
import Addresses from '../views/Addresses.vue'
import AddressForm from '../views/AddressForm.vue'
import Settings from '../views/Settings.vue'
import Checkout from '../views/Checkout.vue'
import Success from '../views/Success.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/about',
    name: 'about',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/AboutView.vue')
  },
  {
    path: '/:category_slug/:product_slug/',
    name: 'Product',
    component: Product
  },
  {
    path: '/search/',
    name: 'Search',
    component: Search
  },
  {
    path: '/sign-up/',
    name: 'SignUp',
    component: SignUp
  },  {
    path: '/my-account/',
    name: 'MyAccount',
    component: MyAccount,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/my-account/profile',
    name: 'Profile',
    component: Profile,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/my-account/orders',
    name: 'Orders',
    component: Orders,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/my-account/orders/:id',
    name: 'OrderDetail',
    component: OrderDetail,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/my-account/addresses',
    name: 'Addresses',
    component: Addresses,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/my-account/addresses/new',
    name: 'NewAddress',
    component: AddressForm,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/my-account/addresses/:id',
    name: 'EditAddress',
    component: AddressForm,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/my-account/settings',
    name: 'Settings',
    component: Settings,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/cart/checkout',
    name: 'Checkout',
    component: Checkout,
    meta:{
      requireLogin: true
    }
  },
  {
    path: '/cart/',
    name: 'Cart',
    component: Cart
  },
  {
    path: '/cart/success',
    name: 'Success',
    component: Success
  },
  {
    path: '/log-in/',
    name: 'LogIn',
    component: LogIn
  },
  {
    path: '/:category_slug/',
    name: 'Category',
    component: Category
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

router.beforeEach((to, from, next) => {
  if(to.matched.some(record => record.meta.requireLogin) && !store.state.isAuthenticated) {
    next({ name: 'LogIn', query: { to: to.path } });
  } else {
    next()
  }
})

export default router
