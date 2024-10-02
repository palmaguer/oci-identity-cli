const axios = require('axios');
const Config = require('../config/config');
const OAuth2 = require('../api/oauth2'); // Use the OAuth2 class for token management
const { logger } = require('../utils');  // Custom logger

class Groups {
  constructor(envfile) {
    // Load the configuration and initialize OAuth2 for token management
    this.config = new Config(envfile);
    this.baseUrl = this.config.getIdentityOAuthConfig().apiBaseUrl;
    this.oauth2 = new OAuth2(envfile);
  }

  // Method to search (list) groups with optional filtering
  async search(queryParams = {}) {
    try {
      const token = await this.oauth2.getToken(); // Fetch token
      const apiUrl = `${this.baseUrl}${Config.identityApi.groupEndpoint}`;

      const query = Object.keys(queryParams)
        .filter(key => queryParams[key] !== undefined && queryParams[key] !== null && queryParams[key] !== '')
        .map(key => `${key}=${queryParams[key]}`)
        .join('&');

      //const url = filter ? `${apiUrl}?filter=${filter}` : apiUrl;
      const url = query ? `${apiUrl}?${query}` : apiUrl;

      const response = await axios.get(url, {
        headers: {
          Authorization: `Bearer ${this.oauth2.getAccessToken()}`, // Use token in Authorization header
        }
      });

      return response.data; // Return the list of groups
    } catch (error) {
      logger.error('Error fetching groups: %s', JSON.stringify(error.response?.data) || error.message);
      throw error;
    }
  }

  // TODO: Deprecated
  // Method to get group details by groupId
  // async getGroupById(groupId) {
  //   try {
  //     const token = await this.oauth2.getToken(); // Fetch token
  //     const apiUrl = `${this.baseUrl}${Config.identityApi.groupEndpoint}/${groupId}`;

  //     const response = await axios.get(apiUrl, {
  //       headers: {
  //         Authorization: `Bearer ${this.oauth2.getAccessToken()}`,
  //       },
  //     });

  //     return response;
  //   } catch (error) {
  //     logger.error('Error fetching group details: %s', JSON.stringify(error.response?.data) || error.message);
  //     throw error;
  //   }
  // }

  // Method to create a new group
  async createGroup(data) {
    try {
      const token = await this.oauth2.getToken(); // Fetch token
      const url = `${this.baseUrl}${Config.identityApi.groupEndpoint}`;

      const response = await axios.post(url, data, {
        headers: {
          Authorization: `Bearer ${this.oauth2.getAccessToken()}`, // Include token in the header
          'Content-Type': 'application/json'
        }
      });

      return response.data; // Return the created group data
    } catch (error) {
      logger.error('Error creating group: %s', JSON.stringify(error.response?.data) || error.message);
      throw error;
    }
  }

  // Method to patch the group with provided payload
  async patchGroup(groupId, payload) {
    try {
      const token = await this.oauth2.getToken(); // Fetch OAuth token
      const apiUrl = `${this.baseUrl}${Config.identityApi.groupEndpoint}/${groupId}`;

      // Perform PATCH request with the provided payload
      const response = await axios.patch(apiUrl, payload, {
        headers: {
          Authorization: `Bearer ${this.oauth2.getAccessToken()}`,
          'Content-Type': 'application/scim+json'
        }
      });

      logger.info(`Successfully updated group ${groupId}`);
      return response.data;
    } catch (error) {
      logger.error(`Error updating group ${groupId}: ${JSON.stringify(error.response?.data) || error.message}`);
      throw error;
    }
  }

  // Method to delete a group by groupId
  async deleteGroup(groupId) {
    try {
      const token = await this.oauth2.getToken(); // Fetch token
      const apiUrl = `${this.baseUrl}${Config.identityApi.groupEndpoint}/${groupId}`;

      const response = await axios.delete(apiUrl, {
        headers: {
          Authorization: `Bearer ${this.oauth2.getAccessToken()}`, // Include token in the header
        },
      });

      return response.data; // Return deletion confirmation
    } catch (error) {
      logger.error('Error deleting group: %s', JSON.stringify(error.response?.data) || error.message);
      throw error;
    }
  }
}

module.exports = Groups;