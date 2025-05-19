<template>
    <div class="page-my-account">
        <div class="columns is-multiline">
            <div class="column is-12">
                <h1 class="title">My Account</h1>
            </div>

            <div class="column is-3">
                <div class="card account-sidebar">
                    <div class="card-content">
                        <div class="media">
                            <div class="media-left">
                                <figure class="image is-48x48">
                                    <img src="https://bulma.io/images/placeholders/96x96.png" alt="Avatar" class="is-rounded">
                                </figure>
                            </div>
                            <div class="media-content">
                                <p class="title is-4">{{ userFirstName }}</p>
                                <p class="subtitle is-6">{{ userData.email }}</p>
                            </div>
                        </div>
                        
                        <div class="menu mt-4">
                            <ul class="menu-list">
                                <li>
                                    <router-link to="/my-account/profile" active-class="is-active">
                                        <span class="icon-text">
                                            <span class="icon"><i class="fas fa-user"></i></span>
                                            <span>Profile</span>
                                        </span>
                                    </router-link>
                                </li>
                                <li>
                                    <router-link to="/my-account/orders" active-class="is-active">
                                        <span class="icon-text">
                                            <span class="icon"><i class="fas fa-shopping-bag"></i></span>
                                            <span>Orders</span>
                                        </span>
                                    </router-link>
                                </li>
                                <li>
                                    <router-link to="/my-account/addresses" active-class="is-active">
                                        <span class="icon-text">
                                            <span class="icon"><i class="fas fa-map-marker-alt"></i></span>
                                            <span>Addresses</span>
                                        </span>
                                    </router-link>
                                </li>
                                <li>
                                    <router-link to="/my-account/settings" active-class="is-active">
                                        <span class="icon-text">
                                            <span class="icon"><i class="fas fa-cog"></i></span>
                                            <span>Settings</span>
                                        </span>
                                    </router-link>
                                </li>
                                <li>
                                    <a @click="logout()" class="has-text-danger">
                                        <span class="icon-text">
                                            <span class="icon"><i class="fas fa-sign-out-alt"></i></span>
                                            <span>Log out</span>
                                        </span>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <div class="column is-9">
                <div v-if="$route.path === '/my-account/'" class="card">
                    <div class="card-content">
                        <div class="columns">
                            <div class="column is-6">
                                <div class="account-summary-widget">
                                    <div class="icon-container has-background-primary">
                                        <span class="icon is-large">
                                            <i class="fas fa-shopping-bag fa-2x has-text-white"></i>
                                        </span>
                                    </div>
                                    <div class="content">
                                        <p class="heading">Orders</p>
                                        <p class="title">{{ orders.length }}</p>
                                        <router-link to="/my-account/orders" class="button is-small is-outlined is-primary">View All</router-link>
                                    </div>
                                </div>
                            </div>
                            <div class="column is-6">
                                <div class="account-summary-widget">
                                    <div class="icon-container has-background-info">
                                        <span class="icon is-large">
                                            <i class="fas fa-map-marker-alt fa-2x has-text-white"></i>
                                        </span>
                                    </div>
                                    <div class="content">
                                        <p class="heading">Addresses</p>
                                        <p class="title">{{ addresses.length }}</p>
                                        <router-link to="/my-account/addresses" class="button is-small is-outlined is-info">View All</router-link>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="recent-orders mt-5">
                            <h3 class="subtitle is-4">Recent Orders</h3>
                            <table class="table is-fullwidth">
                                <thead>
                                    <tr>
                                        <th>Order #</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Total</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="order in recentOrders" :key="order.id">
                                        <td>#{{ order.id }}</td>
                                        <td>{{ formatDate(order.created_at) }}</td>
                                        <td>
                                            <span class="tag" :class="getStatusClass(order.status)">
                                                {{ order.status }}
                                            </span>
                                        </td>
                                        <td>${{ order.total }}</td>
                                        <td>
                                            <router-link :to="'/my-account/orders/' + order.id" class="button is-small">
                                                Details
                                            </router-link>
                                        </td>
                                    </tr>
                                    <tr v-if="orders.length === 0">
                                        <td colspan="5" class="has-text-centered">No orders yet</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <router-view v-else></router-view>
            </div>
        </div>
    </div>
</template>

<script>
import axios from 'axios'

export default {
    name: 'MyAccount',
    data() {
        return {
            orders: [],
            addresses: [],
            userData: {
                email: '',
                name: ''
            }
        }
    },
    computed: {
        recentOrders() {
            return this.orders.slice(0, 5)
        },
        userFirstName() {
            if (this.userData.name) {
                return this.userData.name.split(' ')[0]
            }
            return localStorage.getItem('username') || 'User'
        }
    },
    mounted() {
        document.title = 'My Account | V-Market'
        this.getUserData()
        this.getMyOrders()
        this.getAddresses()
    },
    methods: {
        logout() {
            axios.defaults.headers.common["Authorization"] = ""
            localStorage.removeItem("token")
            localStorage.removeItem("username")
            localStorage.removeItem("userid")
            this.$store.commit('removeToken')
            this.$router.push('/')
        },
        async getUserData() {
            this.$store.commit('setIsLoading', true)
            await axios
                .get('/api/v1/users/me/')
                .then(response => {
                    this.userData = response.data
                })
                .catch(error => {
                    console.log(error)
                })
            this.$store.commit('setIsLoading', false)
        },
        async getMyOrders() {
            this.$store.commit('setIsLoading', true)
            await axios
                .get('/api/v1/orders/')
                .then(response => {
                    this.orders = response.data
                })
                .catch(error => {
                    console.log(error)
                })
            this.$store.commit('setIsLoading', false)
        },
        async getAddresses() {
            this.$store.commit('setIsLoading', true)
            await axios
                .get('/api/v1/addresses/')
                .then(response => {
                    this.addresses = response.data
                })
                .catch(error => {
                    console.log(error)
                })
            this.$store.commit('setIsLoading', false)
        },
        formatDate(dateString) {
            const options = { year: 'numeric', month: 'short', day: 'numeric' }
            return new Date(dateString).toLocaleDateString(undefined, options)
        },
        getStatusClass(status) {
            switch(status.toLowerCase()) {
                case 'pending':
                    return 'is-warning'
                case 'processing':
                    return 'is-info'
                case 'shipped':
                    return 'is-primary'
                case 'delivered':
                    return 'is-success'
                case 'cancelled':
                    return 'is-danger'
                default:
                    return 'is-light'
            }
        }
    }
}
</script>

<style scoped>
.account-sidebar {
    height: 100%;
}

.account-summary-widget {
    display: flex;
    align-items: center;
    padding: 1rem;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    border-radius: 4px;
    height: 100%;
}

.icon-container {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 64px;
    height: 64px;
    border-radius: 50%;
    margin-right: 1rem;
}

.account-summary-widget .content {
    flex: 1;
}

.recent-orders {
    margin-top: 2rem;
}

.mt-4 {
    margin-top: 1rem;
}

.mt-5 {
    margin-top: 1.5rem;
}
</style>