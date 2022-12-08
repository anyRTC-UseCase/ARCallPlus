import Axios from "./axios";

/**
 * 封装 post
 * @param url
 * @param data
 * @returns
 */
export function post(url: string, data = {}) {
  return new Promise<any>((resolve, reject) => {
    Axios.post(url, data).then(
      (response) => {
        if (response) {
          resolve(response.data);
        }
      },
      (err) => {
        reject(err);
      }
    );
  });
}

/**
 * 封装 get
 * @param url
 * @param data
 * @returns
 */
export function get(url: string, params = {}) {
  return new Promise((resolve, reject) => {
    Axios.get(url, params)
      .then((res) => {
        resolve(res.data);
      })
      .catch((err) => {
        reject(err.data);
      });
  });
}
