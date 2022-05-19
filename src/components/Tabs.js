import Form from "./Form";

const Tabs = ({ addCar, cars, likeCar, dislikeCar, address, buyCar }) => {
  return (
    <main>
      <div className="row row-cols-1 row-cols-md-3 mb-3 text-center">
        {cars.map((car) => {
          return (
            <div className="col">
              <div className="card mb-4 rounded-3 shadow-sm">
                <div className="card-header py-3">
                  <h4 className="my-0 fw-normal">{car.name}</h4>
                </div>
                <div className="card-body">
                  <img src={car.imageUrl} width={180} alt="" />
                  <h1 className="card-title pricing-card-title">
                    ${car.amount}
                    <small className="text-muted fw-light">/cUSD</small>
                  </h1>
                  <ul className="list-unstyled mt-3 mb-4">
                    <p>{car.description}</p>
                  </ul>
                  <div className="d-flex justify-content-between">
                    <div
                      style={{ cursor: "grab" }}
                      onClick={() => likeCar(car.index)}
                    >
                      <i class="bi bi-hand-thumbs-up"></i>
                      <p>{car.likes.length} Likes</p>
                    </div>
                    <div
                      style={{ cursor: "grab" }}
                      onClick={() => dislikeCar(car.index)}
                    >
                      <i class="bi bi-hand-thumbs-down"></i>
                      <p>{car.dislikes.length} Dislikes</p>
                    </div>
                  </div>
                  {car.owner !== address && (
                    <button
                      type="button"
                      onClick={() => buyCar(car.index)}
                      className="w-100 btn btn-lg btn-outline-primary"
                    >
                      Buy Now
                    </button>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>
      <Form addCar={addCar} />
    </main>
  );
};

export default Tabs;
